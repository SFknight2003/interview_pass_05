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
