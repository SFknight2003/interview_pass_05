import { webview } from '@kit.ArkWeb'
import { router } from '@kit.ArkUI'
import { HmNavBar } from '../common/components'

interface WebPageParams {
  title: string
  src: string
}

@Entry
@Component
struct WebPage {
  @State title: string = ''
  @State src: string = ''
  controller = new webview.WebviewController()
  @StorageLink("bottomHeight")bottomHeight:number = 0

  // 从router中获取参数
  aboutToAppear(): void {
    const params = router.getParams() as WebPageParams
    this.title = params.title
    this.src = params.src
  }

  build() {
    Column() {
      HmNavBar({ title: this.title, showRightIcon: false })
      Web({ src: this.src, controller: this.controller })
        .layoutWeight(1)
        .width('100%')
        // .margin({
          // bottom : 12
        // })
    }
    .padding({
      bottom:this.bottomHeight
    })
    .height('100%')
    .width('100%')
  }
}