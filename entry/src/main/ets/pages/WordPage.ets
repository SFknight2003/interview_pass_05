import { HmNavBar } from '../common/components'
import { WordItem, Words } from '../models'
import { util } from '@kit.ArkTS'
import { getStrFromJson, logger } from '../common/utils'
import { webview } from '@kit.ArkWeb'
import { WordDialog } from '../views/Word/WordDialog'

@Entry
@Component
struct WordPage {
  // json文件中所有的单词
  words:Words = {}
  // 当前激活的单词
  @State
  wordKey:string = ''
  // 当前渲染代码
  @State
  currentCode:string = ''
  // 滚动条控制器
  scroller:Scroller = new Scroller()
  // 详情代码控制器
  webController = new webview.WebviewController()
  // 播放单词
  @State currentEn: string = ''
  @State currentZh: string = ''

  aboutToAppear(): void {
    // 单词加载
    this.initWord()
  }

  initWord(){
    // 1、读取json文件 --> 二进制流
    // const stream = getContext().resourceManager.getRawFileContentSync('word.json')
    // 2、流转json格式数据 --> json字符串
    // const str = new util.TextDecoder().decodeWithStream(stream)
    const str = getStrFromJson('word.json')
    this.words = JSON.parse(str) as Words
    this.wordKey = Object.keys(this.words)[0] // 从所有单词中，获取key。取第0个
  }

  // 单词分类选择builder
  @State showTypeSheet: boolean = false
  // 代码详情builder
  @State showCodeSheet: boolean = false

  @Builder
  TypeSheetBuilder() {
    Column() {
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        ForEach(Object.keys(this.words), (key: string) => {
          Button() {
            Text(key)
              .fontSize(14)
              .fontColor(key === this.wordKey ? $r('app.color.common_green') : $r('app.color.common_gray_01'))
          }
          .backgroundColor($r('app.color.common_gray_bg'))
          .padding({
            top: 6,
            right: 12,
            bottom: 6,
            left: 12
          })
          .margin({ right: 12, bottom: 12 })
          .onClick(() => {
            this.wordKey = key
            this.showTypeSheet = false
            // 滚到顶部
            this.scroller.scrollEdge(Edge.Top)
          })
        })
      }
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 34 })
  }

  // 详情代码builder
  @Builder
  CodeSheetBuilder() {
    Column() {
      Web({ src: $rawfile('word.html'), controller: this.webController })
        .width('100%')
        .height(400)
        .backgroundColor($r('app.color.common_gray_bg'))
        .onPageEnd(() => {
          this.webController.runJavaScript(`writeHtml(\`${this.currentCode}\`)`)  // 直接传入code
        })
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 34 })
  }

  // 音频播放
  wordController = new CustomDialogController({
    builder: WordDialog({ en: this.currentEn, zh: this.currentZh }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  build() {
    Column() {
      HmNavBar({ title: '常用单词', showRightIcon: false })
      Row() {
        Column({ space: 4 }) {
          Text('开发常用词汇')
          Text(`共 0 个单词`)
            .fontSize(12)
            .fontColor($r('app.color.common_gray_03'))
        }
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(this.wordKey)
            .fontSize(12)
            .fontColor($r('app.color.common_gray_01'))
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .width(16)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
        }
        .bindSheet($$this.showTypeSheet, this.TypeSheetBuilder(), {   // 展示弹层
          title: {title: '选择技术分类'},
          backgroundColor: $r('app.color.white'),
          height: 400
        })
        .onClick(()=>{
          this.showTypeSheet = true   // 展示弹层
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
      .border({ width: { top: 0.5 }, color: $r('app.color.common_gray_bg') })

      Divider()
        .strokeWidth(8)
        .color($r('app.color.common_gray_bg'))

      // 绑定滚动
      List({scroller : this.scroller}) {
        // wordKey对应的数组
        ForEach(this.words[this.wordKey], (item: WordItem) => {

          ListItem() {
            Row({ space: 6 }) {
              Image($r('sys.media.ohos_ic_public_sound'))
                .width(20)
                .aspectRatio(1)
                .alignSelf(ItemAlign.Start)
                .fillColor($r('app.color.common_gray_03'))
                .onClick(() => {  // 音频播放
                  this.currentEn = item.en
                  this.currentZh = item.zh
                  this.wordController.open()
                })
              Column({ space: 10 }) {
                Text(item.en)
                  .fontWeight(FontWeight.Bold)
                Text(item.zh)
                  .fontSize(14)
                  .fontColor($r('app.color.common_gray_03'))
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Row() {
                Text('详细代码')
                  .fontSize(12)
                  .fontColor($r('app.color.common_gray_01'))
                Image($r('sys.media.ohos_ic_public_arrow_right'))
                  .width(16)
                  .aspectRatio(1)
                  .fillColor($r('app.color.common_gray_01'))
              }
              .visibility(item.code ? Visibility.Visible : Visibility.Hidden)   // 如果有详细代码则展示按钮
              .alignSelf(ItemAlign.End)
              .onClick(()=>{
                this.currentCode = item.code
                this.showCodeSheet = true
              })
            }
            .padding(16)
          }
        })
      }
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.common_gray_bg')
      })
      .layoutWeight(1)
      .bindSheet($$this.showCodeSheet, this.CodeSheetBuilder(), {
        title: {title : '详细代码'},
        detents: [SheetSize.FIT_CONTENT], // 设置大小自适应
        backgroundColor: $r('app.color.white')
      })
    }
    .width('100%')
    .height('100%')
  }
}