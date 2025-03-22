import axios, { AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from "@ohos/axios"
import { promptAction } from "@kit.ArkUI"

// 后台给的数据结构定死了
interface Res<T> {
  success : boolean
  code : number
  message : string
  data : T
}

// 请求根地址 + 超时时长配置
export const baseURL = 'https://api-harmony-teach.itheima.net/'
export const timeout = 10 * 1000
// 添加应用配置，创建axios实例
const instance = axios.create({
  baseURL,
  timeout
})

// 拦截器：
// 请求拦截器：请求发送到服务器之前的一次拦截 - 设置请求配置信息（携带token参数）
// 响应拦截器：收到服务器响应结果响应之前的一次拦截 - 数据处理，异常处理（返回结果的处理）

// 成功 失败两种状态
    // config 请求配置（请求头，地址，参数等）
instance.interceptors.request.use((config:InternalAxiosRequestConfig)=>{
  // TODO:业务：携带登录信息
  return config
},(err:Error)=>{  // 错误返回一个Error对象
  promptAction.showToast({
    message:'请求参数错误'
  })
  return Promise.reject(err)
})

instance.interceptors.response.use((res:AxiosResponse)=>{
  // TODO:数据加工处理
  // 1、接口调通了
  // 业务成功/业务失败
  if(res.data.code === 10000) {
    // 返回成功结果 - 返回错误结果
    return res.data.data
  }
  // 2、接口没调通
  // 错误信息
  return Promise.reject(new Error(JSON.stringify(res.data)))
}, (err:Error)=>{
  promptAction.showToast({
    message:'响应错误：' + err.message
  })
  return Promise.reject(err)
})

// =====================================================

class Http {
  //ResponseData 是调用时传递的类型，标识返回值的类型
  request<ResponseData,RequestData = object>(config:AxiosRequestConfig<RequestData>) {  // 给请求参数默认值
    // 二次封装：传递参数，该修改的地方修改 该包装的地方包装
    // 1、只需要传递相应结果的类型
      // null泛型接收的参数
    return instance<null,ResponseData,RequestData>(config)  // 将第一个参数写死，只需要传入两个二参数
  }
}

export const http = new Http()