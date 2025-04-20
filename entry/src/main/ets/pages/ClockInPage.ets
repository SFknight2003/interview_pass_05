import { HmCalendar, HmCalendarSelectedDay } from '@ohmos/calendar'
import { HmNavBar } from '../common/components'
import { http, logger } from '../common/utils'
import { ClockInfo, ClockInfoParams } from '../models'

interface DayBuilderParams {
  day: number
  text: string
}

@Entry
@Component
struct ClockInPage {

  @Builder
  dayBuilder(params: DayBuilderParams) {
    Column() {
      Row() {
        Text(params.day.toString())
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
        Text('天')
          .fontSize(10)
          .fontColor($r('app.color.common_gray_01'))
          .margin({ bottom: 8, left: 10 })
      }
      .alignItems(VerticalAlign.Bottom)
      Text(params.text)
        .fontSize(10)
        .fontColor($r('app.color.common_gray_01'))
    }.margin({ right: 36 })
  }

  @State clockInfo: ClockInfo = {
    // 给初始值，用于aboutToAppear提前渲染不报错
    flag: false,
    clockinNumbers: 0,
    totalClockinNumber: 0,
    clockins: []
  }

  //选中的日期
  @State selectedDays: HmCalendarSelectedDay[] = [] // 组件中已经定义好了的类型

  aboutToAppear(): void {
    const current = new Date()
    this.getClockInfo({ year: current.getFullYear().toString(), month: (current.getMonth() + 1).toString() })
  }
  // 发请求获取打卡数据
  async getClockInfo (params: ClockInfoParams) {
    const res = await http.request<ClockInfo>({ url: 'hm/clockinInfo', params })  // 请求打卡信息
    this.clockInfo = res  // 响应结果赋值
    console.log('interview_pass_log','ClockInPage','53=>',"打卡成功：" + JSON.stringify(res))
    this.selectedDays = res.clockins.map(item=>({ date: item.createdAt } as HmCalendarSelectedDay)) // 取出所有的createdAt值
  }

  build() {
    Column({ space: 16 }) {
      HmNavBar({ title: '每日打卡', showRightIcon: false })
      Row() {
        this.dayBuilder({ day: this.clockInfo.totalClockinNumber, text: '累计打卡' })
        this.dayBuilder({ day: this.clockInfo.clockinNumbers, text: '连续打卡' })
      }
      .padding({ top: 10, bottom: 25, left: 16, right: 16 })
      .width('100%')
      .justifyContent(FlexAlign.Start)
      Row() {
        // 需要传递当前时间 以及选中时间
        HmCalendar({
          selectedDays :  this.selectedDays,
          onChangeMonth : (month) => {  // 租价返回年月值：2025-04
            const arr = month.split("-")  // 切割数据
            this.getClockInfo({   // 通过组件封装好的回调函数，重新传入调用 获取打卡数据
              year : arr[0],
              month : arr[1]
            });
          }
        })  // 传入选中日期
          .borderRadius(8)
          .border({ width: 0.5, color: '#ededed' })
          .shadow({ color: '#ededed', radius: 16 })
          .backgroundColor($r('app.color.white'))
      }
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.clocked_bg'))
    .backgroundImageSize({ width: '100%' })
  }
}
