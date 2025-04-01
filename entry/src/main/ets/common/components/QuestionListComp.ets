import { QuestionItemComp } from '.'
import { PageData, QuestionDetail, QuestionItem, QuestionListParams, QuestionPageParams, SortType } from '../../models'
import { http } from '../utils/Http'
import { promptAction, router } from '@kit.ArkUI'
import { auth } from '../utils'

@Component
export struct QuestionListComp {
  @State list: QuestionItem[] = []
  // 控制刷新的状态
  @State isRefreshing: boolean = false
  // 正在加载中...
  @State isLoading: boolean = false
  // 是否加载完成(所有数据)
  @State isFinished: boolean = false
  // 分类id
  @Prop typeId : number
  @Prop activeIndex : number
  @Prop index : number
  // 排序
  @Prop @Watch('onChangSort') sort : SortType = SortType.Default
  onChangSort(){
    // 是不是当前要更新
    if ( this.activeIndex === this.index ) {
      this.isRefreshing = true  // 排序方式改变，切换到自动下拉
    }
  }
  // 当前页数
  @State page : number = 1
  // 下拉刷新加载
  async onRefresh() {
    /* 模拟
    setTimeout(() => {
      this.isRefreshing = false // 模拟1s后加载结束
    }, 1000)
     */
    this.page = 1
    const res = await this.getQuestionList()  // 数组
    this.list = res.rows  // 覆盖
    this.isRefreshing = false
    if (this.page >= res.pageTotal){
      this.isFinished = true
    } else {
      this.isFinished = false
      this.page ++    // 下一页数据加载同步
    }
    promptAction.showToast({
      message : "更新成功"
    })
  }
  // 上拉滚动加载逻辑
  async onLoad() {
    /* 模拟数据加载
    setTimeout(() => {
      for (let i = 0; i < 10; i++) {
        this.list.push({} as QuestionItem)  // 追加数据
      }
      // 加载到40条数据返回
      if (this.list.length > 30) {
        this.isFinished = true
      }
      // 数据加载完成修改状态变量
      this.isLoading = false
    }, 1000)
     */
    // 获取数据
    const res = await this.getQuestionList()  // 数组
    this.list.push(...res.rows)   // 逐一追加
    this.isLoading = false
    // 是否最后一页
    if (this.page >= res.pageTotal) {
      this.isFinished = true
    } else {
      // 让下一页数据加载同步
      this.page ++
    }
 }
  // loading加载 展示的builder
  @Builder
  LoadMoreBuilder() {
    ListItem(){
      if (this.isLoading) {
        Row({ space: 4 }) {
          LoadingProgress()   // 加载图标
            .width(20)
          Text('正在加载...')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_01'))
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      } else if (this.isFinished) {
        Text('没有更多了~')
          .fontSize(14)
          .textAlign(TextAlign.Center)
          .width('100%')
          .fontColor($r('app.color.common_gray_01'))
      }
    }.height(80)
  }
  // 获取列表数据方法
  getQuestionList() : Promise<PageData<QuestionItem>> {   // 返回类型
    return http.request<PageData<QuestionItem>>({    // 填写响应结果
      url : 'hm/question/list',
      params : {
        type: this.typeId,
        questionBankType: 10,
        sort: this.sort,
        page: this.page,
        pageSize: 10
      } as QuestionListParams
    })
  }

  build() {
    // 1、下拉刷洗新 - refresh
    Refresh({ refreshing: $$this.isRefreshing }) {    // 绑定刷新状态，下拉变成true
      List() {
        ForEach(this.list, (item:QuestionItem) => {
          ListItem() {
            QuestionItemComp({
              item
            }).onClick(()=>{
              // 不鉴权直接跳转
              // router.pushUrl({
              //   url:'pages/QuestionPage'
              // })
              // 鉴权 - 跳转页面
              auth.checkAuth({
                url:'pages/QuestionPage',
                params: {
                  item,
                  list: this.list
                } as QuestionPageParams
              })
            })
          }
        })
        // loading条展示
        this.LoadMoreBuilder()
      }
      .divider({    // 分隔线
        strokeWidth: 0.5,
        color: $r('app.color.common_gray_border'),
        startMargin: 16,    // 左右间距
        endMargin: 16
      })
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)  // 关闭滚动条
      .edgeEffect(EdgeEffect.None)  // 无弹簧模式(弹簧模式需要添加一个标记判断是否触底)
      .onReachEnd(() => {   // 触底操作
        if (this.isLoading || this.isFinished || this.isRefreshing ) {  // 如果下拉中、加载完成、正在加载，直接返回避免二次加载
          return
        }
        this.isLoading = true   // 开始加载数据修改状态
        this.onLoad()
      })
      /*
      弹簧模式下会触底两次
      .onScrollStart(()=>{  开始滑动  })
      .onReachEnd(()=>{
        promptAction.showToast({
          message: '我触底了'
        })
      })
      .onScrollStop(()=>{  停止滑动  })
       */
    }
    .onRefreshing(()=>{  // 下拉时触发，定时关闭
      this.onRefresh()
    })
  }
}

