import { TimeItem } from '../../models'
import { http } from './Http'
import { logger } from './Logger'
import { preferences } from '@kit.ArkData'
import { JSON } from '@kit.ArkTS'

class Tracking {
  // 定义缓存列表，缓存记录点
  // list: TimeItem[] = []

  // 首选项：仓库-> key -> 通过key val存储
  store:preferences.Preferences | null = null
  // 用于仓库读写的 key
  trackKey:string = 'track-list'

  // 仓库创建
  getStore() {
    if (!this.store) {
      const context = AppStorage.get<Context>('context')
      this.store = preferences.getPreferencesSync(context, { name: 'tracking-store' })
    }
    return this.store
  }

  /**
   * @Description: 记录
   * @about: 开始时间，结束时间，问题ID
   * 不是每个点都上述，减小服务器压力
   */
  // record(questionId: string,startTime: number, endTime: number) {
  //   this.list.push({
  //     questionId,
  //     startTime,
  //     endTime
  //   })
  //   logger.info('Tracking：', JSON.stringify(this.list))
  // }
  async record(questionId: string, startTime: number, endTime: number) {
    // 原来数组 + 新增数组 = 完整数组
    const json = this.getStore().getSync(this.trackKey, "[]")
    const list = JSON.parse(json as string) as TimeItem[]   // 原数组
    list.push({    // 新数组
          questionId,
          startTime,
          endTime
        })
    console.log('interview_pass_log','Tracking','41=>',JSON.stringify(list))  // 最新的数组
    this.getStore().putSync(this.trackKey, JSON.stringify(list))    // 转list存入
    // 持久化写入磁盘
    await this.getStore().flush()
  }

  // 请求接口
  // async report() {
  //   await http.request<null>({ url: 'hm/time/tracking', method: 'post', data: { timeList: this.list } })
  //   this.list = []
  // }
  //force：是否主动上报，不够五条也可以上报一下
  // async report(force: boolean = false) {
  //   const json = this.getStore().getSync(this.trackKey, '[]')
  //   const list = JSON.parse(json as string) as TimeItem[]
  //   if (list.length >= 5 || (force && list.length )) {
  //     await http.request<null>({ url: 'time/tracking', method: 'post', data: { timeList: list } })
  //     this.getStore().deleteSync(this.trackKey)
  //     await this.getStore().flush()
  //   }
  // }
  async report(force: boolean = false){ // 默认 force是false
    const json = this.getStore().getSync(this.trackKey, "[]")
    const list = JSON.parse(json as string) as TimeItem[]
    console.log('interview_pass_log','Tracking','71=>', "上报数据：" + JSON.stringify(list))
    // 判断是否需要上传，满5条再上传
    if ( list.length >= 5 || (force && list.length) ) {  // 为true主动上传
      // 上送逻辑
      await http.request<null>({ url: 'hm/time/tracking', method: 'post', data: { timeList: list } })
      this.getStore().deleteSync(this.trackKey)   // 不建议key
      await this.getStore().flush()
      console.log('interview_pass_log','Tracking','78=>','上报成功')
    }
  }
}

export const tracking = new Tracking()