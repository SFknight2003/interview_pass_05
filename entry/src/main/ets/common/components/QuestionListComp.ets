import { QuestionItemComp } from '.'
import { QuestionItem } from '../../models'

@Component
export struct QuestionListComp {
  @State list: QuestionItem[] = []
  // 控制刷新的状态
  @State isRefreshing: boolean = false
  // 正在加载中...
  @State isLoading: boolean = false
  // 是否加载完成(所有数据)
  @State isFinished: boolean = false
  // 模拟下拉刷新加载
  onRefresh() {
    setTimeout(() => {
      this.isRefreshing = false // 模拟1s后加载结束
    }, 1000)
  }
  // 上拉滚动加载逻辑
  onLoad() {
    // 模拟数据加载
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

  build() {
    // 1、下拉刷洗你 - refresh
    Refresh({ refreshing: $$this.isRefreshing }) {    // 绑定刷新状态，下拉变成true
      List() {
        ForEach(new Array(10).fill(1), () => {
          ListItem() {
            QuestionItemComp({
              item: {
                id: '100',
                stem: '请说下ArkUI的容器组件有哪些？',
                difficulty: 3,
                likeCount: 23,
                views: 423,
                readFlag: 1
              }
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

