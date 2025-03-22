/**
 * @Description: 打印工具
 */
import { hilog } from "@kit.PerformanceAnalysisKit"
const Tag_name : string = 'Interview_Pass'
// 打印 debug
class Logger {
  private domain : number
  private tag:string
  constructor(tag:string = 'Logger',domain:number = 0x0000) {
    this.domain = domain
    this.tag = tag
  }
  format(args:string[]){  // 封装成模板
    let str = ''
    for( let i = 0; i < args.length; i++){
      str += '%{public}s '
    }
    return str
  }
  info(...args:string[]){ // 剩余所有参数以该类型接收
    hilog.info(this.domain,this.tag, this.format(args), args)
  }
  warn(...args:string[]){
    hilog.warn(this.domain,this.tag, this.format(args), args)
  }
  error(...args:string[]){
    hilog.error(this.domain,this.tag, this.format(args), args)
  }
  fatal(...args:string[]){
    hilog.fatal(this.domain,this.tag, this.format(args), args)
  }
  debug(...args:string[]) {
    hilog.debug(this.domain,this.tag, this.format(args), args)
  }
}
// 使用示例
export const logger = new Logger(Tag_name)
