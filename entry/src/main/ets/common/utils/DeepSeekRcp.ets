import { rcp } from "@kit.RemoteCommunicationKit"
import { util } from '@kit.ArkTS';

// 拦截器的class实现并继承 rcp.Interceptor
const APIKey = "sk-ecaacc28992b4b59a644dff15208383c"; // APIkey
const url = "https://api.deepseek.com/chat/completions" // 请求url地址


// 请求拦截器类
class DeepSeekRcpRequest implements rcp.Interceptor {
  intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    context.request.headers!.authorization = `Bearer ${APIKey}`; // 注入apikey
    return next.handle(context)
  }
}

export class DeepSeekRcp {
  session: rcp.Session | null = null // rcp的请求实例对象
  // 接收返回数据
  private cacheMessage: Map<String, String[]> = new Map(); // 暂存消息
  private textCallBack?: (id:string, message: String[], finished: boolean) => void // 不间断调用
  private currentReq: rcp.Request | null = null

  stopPrint() {
    this.session?.cancel(this.currentReq)
  }

  initSession() {
    this.session = rcp.createSession({
      // 注入token的拦截器
      interceptors :[
        new DeepSeekRcpRequest()
      ],
      // 接收二进制数据流（自定义请求的处理逻辑）
      requestConfiguration: {
        tracing: {
          httpEventsHandler: {
            // 接收数据
            onDataReceive: (bf) =>{
               // SSE数据  bf-> json  ArrayBuffer -> Unit8Array
              const uni8 = new Uint8Array(bf)
              // 解码
              const decoder = new util.TextDecoder()
              const str = decoder.decodeToString(uni8)
              // console.log('interview_pass_log','DeepSeekRcp','38=>',"str: " + str)

              // 解析返回数据
                // 1、去除消息放入数组
              const list = str.split("\n")
              // console.log('interview_pass_log','DeepSeekRcp','42=>',"list: " + list)
                // 2、针对每一条数组处理 （把data:截掉，转成json对象）
              for(let item of list){
                const dealStr = item.substring(5) // 第五个字符
                if (dealStr) {
                  // 2.1 把字符串转换成对象
                  const message = JSON.parse(dealStr) as ChatCompletionChunk  // 转成json
                  // 2.2判断map中是否已经缓存了同一条消息的部分内容
                  if(!this.cacheMessage.has(message.id)){
                    this.cacheMessage.set(message.id , [])
                  }
                  // 2.3 添加字符串入map对象，
                  const list = this.cacheMessage.get(message.id)
                  message.choices.map(obj => {
                    list?.push(obj.delta.content) // 放入数组
                  })
                  // 2.4 判断消息是否完成
                  let isFinished = false
                  if (message.choices[0].finish_reason == "stop") {
                    // 此时sse数据结束
                    isFinished = true
                  }
                  // 2.5 消息写入缓存
                  this.cacheMessage.set(message.id, list)
                  console.log('interview_pass_log','DeepSeekRcp','70=>',list)
                  // 2.6 把消息传回界面
                  this.textCallBack?.(message.id, list, isFinished)
                  // 2.7 判断消息是否完成
                  if(isFinished){
                    this.cacheMessage.delete(message.id)
                  }
                }
              }
            }
          }
        }
      }
    })
  }

  // 1、发送问题给deepSeek
  postDeepSeek(data: object, callback?:(id:string, message:String[],finished:boolean)=>void) { // 接收回调函数
    if (!this.session) {
      this.initSession()
    }

    // 方便上面方法调用该回调函数
    this.textCallBack = callback

    // 1.1 发起请求
    // 不能立即得到全部结果（流返回）
    // this.session?.post(url, data) // 写入请求地址和数据

    // 发送deepSeek请求 不能立刻渴望得到结果 内容推理 一个字一个字在推
    this.currentReq = new rcp.Request(url, "POST", {}, data)
    this.session?.fetch(this.currentReq);
  }
}

export const deepSeekRcp = new DeepSeekRcp()

interface ChatCompletionChunk {
  id: string;
  object: string;
  created: number;
  model: string;
  choices: ChoiceItem[];  // 存放content [{"index":0,"delta":{"content":"返回内容"},"logprobs":null,"finish_reason":null}]
  usage: UsageItem;   // 最后一个返回才会有
}

interface ChoiceItem {
  index: number;
  delta: deltaItem;
  logprobs: null;
  finish_reason: string | null;

}

interface deltaItem {
  role: string;
  content: string;
}

interface UsageItem {
  prompt_tokens: number;
  total_tokens: number;
  completion_tokens: number;
}