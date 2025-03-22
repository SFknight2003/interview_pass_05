@Component
export struct CustomCalendar {
  // 枚举、数组
  monthArr:string[] = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
    // 0 - 11
  @State
  month:number = 0
    // 1 - 31
  @State
  date:number = 1
    // 月份天数
  @State
  day:number = 30
  @State
  offsetDay:number = 1

  aboutToAppear(): void {
    // 获取当前月、日
    const dateObj = new Date
    this.month = dateObj.getMonth()
    this.date = dateObj.getDate()
    // 计算月份天数
        // 下个月的时间戳 - 当前时间戳
        // 时间戳差 / （24*60*60*1000） = 多少天
    const nextTemp = new Date(dateObj.getFullYear() + '-' + (this.month + 2) + '-' + this.date).getTime()
    const currentTemp = new Date(dateObj.getFullYear() + '-' + (this.month + 1) + '-' + this.date).getTime()
    this.day = (nextTemp - currentTemp) / (1000 * 60 * 60 * 24)
    // 获取星期
    this.offsetDay = new Date(dateObj.getFullYear() + '-' + (this.month + 1)).getDay()
    }

  build() {
    Row(){
      Row(){
        // 文字日历
        Column({space : 6}){
          Text(this.monthArr[this.month])
            .fontColor('#ffe52f2f')
          Text(this.date.toString().padStart(2,'0'))    // 补齐两位 前面填充0
            .fontWeight(FontWeight.Bold)
            .fontSize(32)
        }
        .padding(12)
        .backgroundColor($r('app.color.white'))
        .borderRadius(6)
        .shadow(4)
        .position({
          x:16,
          y:-16
        })
        // 每日推荐文字
        Column({space : 6}){
          Text('每日一题').fontSize(14)
          Text('ArkTs 有哪些组件嵌套？')
            .fontWeight(FontWeight.Bold)
            .fontSize(16)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({
          left:100
        })

        // 日历图标

        // 日历图表
        Column() {
          GridRow({ columns: 7, gutter: 6 }) {  // 列，间距
            // 空白偏移 1-6->0-5  0天->6
            ForEach(Array(this.offsetDay === 0 ? 6 : this.offsetDay - 1).fill(() => 1), () => {
              GridCol()   // 填充空白
            })
            // 真正的日期
            ForEach(Array(this.day).fill(() => 1), (item: number, index: number) => {
              GridCol() {
                Row()
                  .width(6)
                  .aspectRatio(1)
                  .borderRadius(3)
                  .backgroundColor(this.date === (index + 1) ? '#ff00d20d' : '#ccc')  // 日期和下标+1相等
              }
            })
          }
        }
        .width(120)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .padding({
          right: 16
        })
      }
      .width('100%')
      .height(80)
      .borderRadius(6)
      .backgroundColor($r('app.color.common_gray_border'))
    }
    .width('100%')
    .padding({
      left:16,
      right:16
    })
  }
}
