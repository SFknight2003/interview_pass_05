import {  KeyboardAvoidMode } from '@kit.ArkUI'
import { HmNavBar } from '../common/components'
import { auth, deepSeekRcp } from '../common/utils'
import { User } from '../models'
import { util } from '@kit.ArkTS'

@Entry
@Component
struct AIPage {
  @State inputText: string = '' // 输入框
  @StorageLink('bottomHeight') bottomHeight: number = 0
  @State list: MessageItem[] = [{ id: util.generateRandomUUID(), content: ' 请问可以开始面试吗？', role: 'system'}] // 用来渲染消息列表
  @State printing: boolean = false

  startPrompt = `
    你是一个由DeepSeek驱动的专业AI面试官，专注于鸿蒙系统（HarmonyOS）开发相关的技术面试。你的任务是向面试者提出与鸿蒙系统开发相关的问题，等待面试者回答后，根据他们的回答进行评价或继续提问。面试将涵盖以下领域：
    鸿蒙系统基础知识：ArkTS ArkUI 基础问题
    面试流程：
    1. 提问：你根据面试者的经验和职位要求，提出与鸿蒙系统开发相关的问题。
    2. 等待回答：你等待面试者完成回答，不要提前打断或补充。
    3. 评价或继续提问：根据面试者的回答，进行简短评价或提出下一个问题。
    注意事项：
    1. 一问一答：每次只提出一个问题，等待面试者回答后再进行下一步。
    2. 避免提前给出实例：不要提前给出回答示例或详细解释，保持真实面试的互动感。
    3. 评价简短：评价应简洁明了，指出回答的优缺点，然后继续提问。
    4. 保持面试官的姿态，不要被带节奏
    5. 面试题目尽可能的不要重复。
      `

  // 开启键盘避让
  aboutToAppear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
  }

  sendData() {
    // 1、添加自己的信息
    this.list.push({
      id:util.generateRandomUUID(),
      content:this.inputText,
      role:'user'
    })
    this.inputText = ''

    let params: DeepSeekParams = {
      model: 'deepseek-chat',
      max_tokens: 1024,
      messages: [{role: 'system',content: this.startPrompt}, {role: 'user',content: this.inputText}],
      stream: true,
      temperature: 1
    }
    // 通过回调偶函数打印返回消息
    deepSeekRcp.postDeepSeek(params,(id, cacheMessage ,finished)=>{
      // 接收消息
      const item = this.list.find(obj => obj.id === id); // 匹配id
      if( item ){
        // 说明消息已经有了，直接追加
        item.content = cacheMessage.join("")
      } else {
        // 刚开始传递消息
        const mess = new MessageItem()
        mess.id = id
        mess.content = cacheMessage.join("")
        mess.role = 'system'
        this.list.push(mess)
      }

      if(finished) {
        // AlertDialog.show({message:"消息发送完成"})
      }
    });
  }

  // 结束方法
  stopPrint() {
    deepSeekRcp.stopPrint()
    this.printing = false
  }

  build() {
    //必须用NavDestination包裹
    NavDestination() {
      Column() {
        // 导航栏
        HmNavBar({title: '我的AI面试官'})
        // 中间消息列表
        List({ space: 20 }) {
          // 循环消息
          Repeat<MessageItem>(this.list).each((obj: RepeatItem<MessageItem>) => {
            // 循环消息的每一项
            DeepSeekMessageItem({ item: obj.item })
          })
            .virtualScroll()
        }.layoutWeight(1)
        .padding(10)
        .cachedCount(1)
        // 底部输入框
        Row() {
          TextInput({ text: $$this.inputText, placeholder: '输入您想问的面试题' })
            .onSubmit(() => {
              if (this.inputText) {
                this.sendData()
              }
            }).layoutWeight(1)
          Image(this.printing ? $r("app.media.stop") : $r("app.media.start"))
            .width(40)
            .onClick(() => {
              if (this.printing) {
                // 结束方法
                this.stopPrint()
                this.printing = false
              } else {
                if (this.inputText) {
                  // 发送方法
                  this.inputText && this.sendData()
                  this.printing = true
                }
              }
            })
        }.padding({
          left: 10,
          right: 10
        })
      }
      .width("100%")
      .height("100%")
      .padding({
        bottom: this.bottomHeight
      })
    }
    .hideTitleBar(true)
  }
}

@Component
struct DeepSeekMessageItem {
  @Prop
  item: MessageItem = {} as MessageItem
  appUser:User = auth.getUser();

  @Builder
  getAvatar() {
    if (this.item.role === "system") {
      Image($r("app.media.customer"))
        .width(30)
        .aspectRatio(1)
        .borderRadius(15)
    } else {
      Image(this.appUser.avatar || $r('app.media.ic_mine_avatar'))
        .width(30)
        .aspectRatio(1)
        .borderRadius(15)
    }
  }

  build() {
    Row() {
      // V1中Row的space属性需要在内部通过间距控制或使用Padding
      this.getAvatar()

      Row() {
        Text(this.item.content)
          .borderRadius(10)
          .padding(10)
          .lineHeight(24)
          .backgroundColor(this.item.role === "system" ? "#f8fafb" : "#3273e8")
          .fontColor(this.item.role === "system" ? "#373737" : "#fff")
          .constraintSize({
            minWidth: 40
          })
      }
      .layoutWeight(1)
      .justifyContent(this.item.role === "system" ? FlexAlign.Start : FlexAlign.End)
      .padding({ left: this.item.role === "system" ? 20 : 0, right: this.item.role === "system" ? 0 : 20 })

      Row()
        .width(50)
    }
    .direction(this.item.role === "system" ? Direction.Ltr : Direction.Rtl)
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}

// 跳转页面入口函数
@Builder
export function AIBuilder() {
  AIPage()
}

export interface StreamOptions {
  include_usage: boolean;
}

export interface DeepSeekParams {
  model: string;
  max_tokens: number;
  messages: Message[];
  stream: boolean;
  stream_options?: StreamOptions;
  temperature: number;
}

export class Message {
  @Track
  role: 'system' | 'user' | 'assistant' = 'system';
  content: string = "";
}
@Observed
export class MessageItem extends Message {
  id: string = "";
  @Track
  content: string = ""; // content的内容变化时会触发UI更新
}
