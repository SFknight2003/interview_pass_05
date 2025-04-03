import { HmLoadingDialog, HmNavBar, HmTag } from '../common/components'
import { QuestionDetail, QuestionOptParams, QuestionPageParams } from '../models'
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
  // 网页控制器
  controller:WebviewController = new webview.WebviewController
  // 弹层控制器
  loadingController = new CustomDialogController({
    builder: HmLoadingDialog(),
    customStyle: true,    // 自定义样式
    alignment: DialogAlignment.Center   // 对齐方式
  })
  async aboutToAppear() {
    // 跟新页面启动参数
    const params = router.getParams() as QuestionPageParams
    this.item = params.item as QuestionDetail
    this.list = params.list as QuestionDetail[]
    // 找到当前页面在list中的下标
    this.activeIndex = this.list.findIndex(item => item.id === this.item.id)
    this.item = await this.getQuestionDetail(this.item.id)
    // 列表缓存
    this.list[this.activeIndex] = this.item
    // 拿到数据后刷新一次页面
    this.controller.loadUrl($rawfile('question.html'))
  }

  /**
   * @Description:切换方法
   * @about: 传入参数步数，下一题1 上一题-1
   */
  async toggleQuestion (step: number) {
    // 更新索引
    const index = this.activeIndex + step
    // 判断是否超过范围
    if (index < 0 || index >= this.list.length) {
      return promptAction.showToast({ message: '没有更多题了' })
    }
    this.activeIndex = index
    const item = this.list[index]   // 从list中获取数据
    // 请求过的答案进行缓存
    // 第一轮传入进来的list只包含QuestionItem的内容，没有answer
    // 如果此时item没有answer则发送请求 并把list中的值替换成内容
    if ( item.answer ) {
      this.item = item
    } else {
      this.item = await this.getQuestionDetail(item.id)
      this.list[index] = this.item  // 更新列表，存储缓存
    }
    // TODO：加载页面loading
    // TODO：点赞收藏
    // 传入id 获取页面内容
    // 重新加载web答案部分页面
    // this.controller.loadUrl($rawfile('question.html'))
    // 重新运行脚本内容
    this.controller.runJavaScript(`writeHtml(\`${this.item.answer}\`)`)
  }

  /**
   * @Description: 点赞 | 收藏
   * @about: 传入参数：optType 点赞/收藏  flag 是否已点赞/收藏
   */
  async questionOpt(optType: 1 | 2, flag: 0 | 1) {
    try {
      // 请求参数
      const data: QuestionOptParams = {
        id: this.item.id,
        type: 0,  // 试题
        optType   // 点赞/收藏
      }
      // flag 是你要执行的操作 执行 | 取消
      await http.request<null, QuestionOptParams>({
        url: flag === 1 ? 'hm/question/opt' : 'hm/question/unOpt',  // 1 发送点赞/收藏请求
        method: 'post',
        data
      })
      // 修改值
      if (optType === 1) {
        // 点赞
        promptAction.showToast({ message: this.item.likeFlag === 0 ? '点赞成功' : '取消点赞' })
        // 因为不再请求，手动前台数据刷新
        this.item.likeFlag === 0 ? this.item.likeFlag = 1 : this.item.likeFlag = 0
      }
      if (optType === 2) {
        // 收藏
        promptAction.showToast({ message: this.item.collectFlag === 0 ? '收藏成功' : '取消收藏' })
        this.item.collectFlag === 0 ? this.item.collectFlag = 1 : this.item.collectFlag = 0
      }
    } catch (e) {
      promptAction.showToast({ message: '操作失败' })
    }
  }

  // 请求试题详情
  async getQuestionDetail(id:string){
    this.loadingController.open()
    const result = await http.request<QuestionDetail>({
      url : 'hm/question/' + id
    })
    this.loadingController.close()
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
        .onClick(() => this.questionOpt(1, this.item.likeFlag === 0 ? 1 : 0))   // likeFlag 0未赞，1点赞
      MenuItem({ content: '收藏' })
        .onClick(() => this.questionOpt(2, this.item.collectFlag === 0 ? 1 : 0))
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
        // 上一题/下一题高亮
        Row() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(20)
            .aspectRatio(1)
            .fillColor(this.activeIndex <= 0 ? $r('app.color.common_gray_01') : $r('app.color.common_gray_03'))
          Text(' 上一题')
            .fontColor(this.activeIndex <= 0 ? $r('app.color.common_gray_01') : $r('app.color.common_gray_03'))
        }
        .onClick(()=>{
          this.toggleQuestion(-1)
        })

        Row() {
          Text('下一题 ')
            .fontColor(this.activeIndex >= this.list.length-1 ? $r('app.color.common_gray_01') : $r('app.color.common_gray_03'))
          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(20)
            .aspectRatio(1)
            .fillColor(this.activeIndex >= this.list.length-1 ? $r('app.color.common_gray_01') : $r('app.color.common_gray_03'))
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

