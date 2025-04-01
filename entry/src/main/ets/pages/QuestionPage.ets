import { HmNavBar, HmTag } from '../common/components'
import { QuestionDetail, QuestionPageParams } from '../models'
import { promptAction, router } from '@kit.ArkUI'
import { http } from '../common/utils'
import { webview } from '@kit.ArkWeb'

@Entry
@Component
struct QuestionPage {
  @StorageProp('bottomHeight') bottomHeight: number = 0
  // 页面详情
  @State item: QuestionDetail = {} as QuestionDetail
  list: QuestionDetail[] = []
  @State activeIndex:number = 0

  controller:WebviewController = new webview.WebviewController

  async aboutToAppear() {
    // 跟新页面启动参数
    const params = router.getParams() as QuestionPageParams
    this.item = params.item as QuestionDetail
    this.list = params.list as QuestionDetail[]
    // 找到当前页面在list中的下标
    this.activeIndex = this.list.findIndex(item => item.id === this.item.id)

    this.item = await this.getQuestionDetail(this.item.id)
    // 拿到数据后刷新一次页面
    this.controller.loadUrl($rawfile('question.html'))
  }

  /**
   * @Description:切换方法
   * @about: 掺入参数步数，下一题1 上一题-1
   */
  async toggleQuestion (step: number) {
    // 更新索引
    const index = this.activeIndex + step
    // 判断是否超过范围
    if (index < 0 || index >= this.list.length) {
      return promptAction.showToast({ message: '没有更多题了' })
    }
    this.activeIndex = index
    const item = this.list[index]
    // TODO：请求过的答案进行缓存
    // TODO：加载页面loading
    // TODO：点赞收藏
    // TODO：上一题/下一题高亮
    // 传入id 获取页面内容
    this.item = await this.getQuestionDetail(item.id)
    // 重新加载web答案部分页面
    // this.controller.loadUrl($rawfile('question.html'))
    // 重新运行脚本内容
    this.controller.runJavaScript(`writeHtml(\`${this.item.answer}\`)`)
  }

  // 请求试题详情
  async getQuestionDetail(id:string){
    const result = await http.request<QuestionDetail>({
      url : 'hm/question/' + id
    })
    return result
  }

  @Builder
  TitleBuilder(text: string) {
    Row() {
      Text()
        .width(2)
        .height(12)
        .backgroundColor($r('app.color.black'))
        .margin({ right: 13 })
      Text(text)
        .fontWeight(700)
    }
    .width('100%')
    .padding({ top: 10 })
    .height(32)
  }

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem({ content: '点赞' })
      MenuItem({ content: '收藏' })
      MenuItem({ content: '点我反馈' })
      MenuItem({ content: '试题分享' })
    }
    .width(108)
  }

  build() {
    Column() {
      HmNavBar({ title: '试题详情', showRightIcon: false })
      // 题目
      this.TitleBuilder('题目：')
      Text(this.item.stem)
        .width('100%')
        .padding(16)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: 12 }) {
        ForEach(this.item.stage,(item:string)=>{
          HmTag({ text: item, color: '#ff6600' })
        })
        Blank()
        Image($r("app.media.ic_home_more"))
          .width(20)
          .aspectRatio(1)
          .bindMenu(this.MenuBuilder())
      }
      .width('100%')
      .padding({ bottom: 16, left: 16, right: 16 })

      Divider()
        .strokeWidth(8)
        .color($r('app.color.common_gray_bg'))
      // 内容
      this.TitleBuilder('答案：')
      Web({
        src : $rawfile('question.html'),
        controller : this.controller
      })
        .width('100%')
        .layoutWeight(1)
        .onPageEnd(() => {
          if (this.item.answer) {
            this.controller.runJavaScript(`writeHtml(\`${this.item.answer}\`)`)   // 传入答案 要用 `` 模板字符串进行引用
          }
        })

      Row({ space: 80 }) {
        Row() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(20)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
          Text(' 上一题')
            .fontColor($r('app.color.common_gray_01'))
        }
        .onClick(()=>{
          this.toggleQuestion(-1)
        })

        Row() {
          Text('下一题 ')
            .fontColor($r('app.color.common_gray_03'))
          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(20)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_03'))
        }
        .onClick(()=>{
          this.toggleQuestion(1)
        })
      }
      .height(44)
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: this.bottomHeight })
  }
}

