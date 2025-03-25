// @Entry
@Component
export struct ClockIn {
  @Prop
  clockCount:number = 0
  build() {
    Row(){
      if (this.clockCount === 0) {
        Text('打卡')
          .fontSize(18)
          .fontColor($r('app.color.black'))
          .fontWeight(FontWeight.Bold)  // 加粗
          .margin({
            left: 30,
            bottom: 4
          })
      } else {
        Column(){
          Text('已打卡')
            .fontSize(10)
            .fontColor($r('app.color.black'))
          Text(){
            Span((this.clockCount > 999) ? '999' : this.clockCount.toString())  // ui限制最大值999
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
            Span(' 天')
              .fontSize(10)
          }
        }
        .margin({
          left: 30,
          bottom: 5
        })

      }
    }
    .width(74)
    .height(27)
    .backgroundImage(this.clockCount === 0 ? $r('app.media.ic_common_unclock') : $r('app.media.ic_common_clocked'))
    .backgroundImageSize(ImageSize.Contain) // 最长边撑满
  }
}