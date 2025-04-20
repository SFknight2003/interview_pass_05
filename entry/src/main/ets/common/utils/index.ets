import { auth } from './Auth'
import { http } from './Http'
import { promptAction, router } from '@kit.ArkUI'
import { util } from '@kit.ArkTS'

export * from './Logger'
export * from './FullScreen'
export * from './StatusBar'
export * from './Http'
export * from './Auth'
export * from './Tracking'
export * from './History'

const day = 60 * 60 * 24
const hour = 60 * 60
const min = 60

export function formatTime(second:number = 0){
  console.log('interview_pass_log','index','26=>',second)
  if ( second > day) {
    console.log('interview_pass_log','index','28=>', second / day)
    return (second / day).toFixed(1)+'天'
  } else if (second > hour) {
    console.log('interview_pass_log','index','31=>',second / hour)
    return (second / hour).toFixed(1) + '小时'
  } else if (second > min) {
    console.log('interview_pass_log','index','34=>',second / min)
    return (second / min).toFixed(1) + '分钟'
  } else {
    return "暂无数据"
  }
}

// 打卡结果
interface ClockRes {
  clockinNumbers: number
}
// 打卡方法
export const requestClockIn = async () => {
  const user = auth.getUser()
  // 判断是否登录
  if (user.token) {
    // 判断是否打卡
    // 打了直接跳转详情， 没打先打卡后跳转
    if (user.clockinNumbers === 0) {  // 今天没打卡，连续打卡天数为0
      // 还未打卡 - 打卡
      const res = await http.request<ClockRes>({ url: 'hm/clockin', method: 'post' })
        // 更新打卡天数
      user.clockinNumbers = res.clockinNumbers
      auth.setUser(user)
      promptAction.showToast({ message: '打卡成功' })
    }
    // 跳转打卡页面
    router.pushUrl({ url: 'pages/ClockInPage' })
  } else {
    // 不能用鉴权：可能会存在登录了，跳转登录（放行跳转，会漏打卡）
    router.pushUrl({ url: 'pages/LoginPage' })
  }
}

// 计算百分比
export const calcPercentage = (done: number, total: number) => {
  return Math.round(done / total * 100) + '%'   // 四舍五入
}

// 从rawfile目录中读取json文件
// 1、读取json文件 --> 二进制流
// 2、流转json格式数据 --> json字符串
export const getStrFromJson = (path : string) => {
  return new util.TextDecoder().decodeWithStream(getContext().resourceManager.getRawFileContentSync(path))
}

