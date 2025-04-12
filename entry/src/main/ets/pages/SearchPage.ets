import { router } from '@kit.ArkUI'
import { QuestionListComp } from '../common/components'
import { history } from '../common/utils/History'
import { SearchHistory } from '../views/Search/SearchHistory'

@Entry
@Component
struct SearchPage {
  @StorageProp('topHeight') topHeight: number = 0
  @State keyword: string = ''
  @State isSearch: boolean = false

  build() {
    Column() {
      Row({ space: 16 }) {
        Search({ placeholder: '请输入试题关键字', value: this.keyword })
          .placeholderFont({ size: 14 })
          .height(32)
          .layoutWeight(1)
          .defaultFocus(true)
          .onSubmit( value => {
            this.keyword = value  // 点击搜索时改变变量
            this.isSearch = true  // 打开试题列表
            history.setItem(this.keyword) // 存入首选项
          })
          .onChange( value => {   // 强制改变刷新
            this.keyword = value
            if ( !this.keyword ) {
              this.isSearch = false // 关闭列表
            }
          })
        Text('取消')
          .fontColor($r('app.color.black'))
          .fontSize(15)
          .fontWeight(500)
          .onClick(() => router.back())
      }
      .height(64)
      .padding({ left: 16, right: 16 })
      .border({ width: { bottom: 0.5 }, color: $r('app.color.common_gray_border') })

      Column() {
        if (this.isSearch) {
          // 试题列表
          QuestionListComp({
            keyword : this.keyword  // 传入关键字参数
          })
        } else {
          // 给当前页面传入一个搜索方法
          SearchHistory({
            onSearch: keyword => {
              // 进行搜索
              this.keyword = keyword  // 传入搜索词
              this.isSearch = true  // 切换搜索状态
            }
          })
        }
      }
      .layoutWeight(1)
    }
    .padding({ top: this.topHeight })
    .width('100%')
    .height('100%')
  }
}