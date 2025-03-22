import { CustomCalendar, ClockIn, SearchBox } from "../common/components"
import { HomeCategory } from "../common/views/Home/HomeCategory"

@Component
export struct HomePage {
  @StorageLink('topHeight') topHeight : number = 0
  @Builder
  SwiperBuilder(str:ResourceStr){ // 传入图片地址
    Row(){
      Image(str)
        .width('100%')
        .aspectRatio(2.65)  // 固定比例
        .objectFit(ImageFit.Fill) // 图片填充满组件
    }
    .width('100%')
    .padding({
      right:16,
      left:16
    })
  }
  build() {
    Column(){
      // TODO: 扫码组件
      Row({ space : 16 }){
        // 扫码按钮
        Image($r('app.media.ic_home_scan'))
          .width(24)
          .aspectRatio(1)
        // 搜索 - 封装组件
        SearchBox({
          placeholder : '搜索题目',
          layoutWeightValue : 1
        })
        // 打卡
        ClockIn({
          clockCount : 999
        })
      }
      .height(48)
      .width('100%')
      .padding({
        left : 16,
        right : 16
      })
      .margin({
        top: this.topHeight
      })

      // TODO: 轮播组件
      Swiper(){
        // 抽离组件
        ForEach([$r('app.media.banner_ai'), $r('app.media.banner_pj'), $r('app.media.banner_qa')],(str:ResourceStr)=>{
          this.SwiperBuilder(str)
        })
      }
      .margin({ bottom: 22 })
      .autoPlay(true)
      // 指示器
      .indicator(DotIndicator.dot().bottom(4).itemHeight(4).selectedItemHeight(4).selectedColor($r('app.color.white')))

      // TODO: 日历组件
      CustomCalendar()

      // TODO: 试题分类
      Column(){
        HomeCategory()
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.white'))
      .margin({
        top:8
      })
    }
    .width('100%')
    .height('100%')

    .backgroundColor($r('app.color.common_gray_bg'))
  }
}