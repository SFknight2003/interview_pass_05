import { history } from "../../common/utils/History"

interface BtnItem {
  text: string
  onClick?: () => void
}

@Component
export struct SearchHistory {
  @State isDeleting: boolean = false
  @State keywords: string[] = []

  // 当前页面点击搜索记录时，会触发该方法
  // 在外部SearchPage中 向这里面传入一个方法
  onSearch: (val: string) => void = () => {}

  aboutToAppear(): void {
    // 从首选项中获取所有记录
    this.keywords = history.getAll()
  }

  build() {
    // 搜索历史
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
      Row() {
        Text('搜索记录')
          .fontSize(15)
          .fontColor($r('app.color.common_gray_01'))
        Blank()
        if (this.isDeleting) {
          Text() {
            Span('全部删除')
              .onClick(() => {
                //  删除全部
                history.clear()
                this.keywords = history.getAll(); // 跟新当前
                this.isDeleting = false
              })
            Span(' | ')
            Span('完成')
              .onClick(() => {
                this.isDeleting = false
              })
          }
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
        } else {
          Image($r('app.media.ic_public_delete'))
            .width(16)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
            .onClick(() => {
              this.isDeleting = true
            })
        }
      }
      .width('100%')

      if ( this.keywords.length ) {
        ForEach(this.keywords, (keyword: string) => {
          Row({ space: 8 }) {
            Text(keyword)
              .fontSize(14)
              .fontColor('#6F6F6F')
            if (this.isDeleting) {
              Image($r('app.media.ic_public_close'))
                .width(12)
                .aspectRatio(1)
                .fillColor('#878787')
                .onClick(() => {
                  //  删除单个
                  history.deleteItem(keyword)
                  this.keywords = history.getAll(); // 跟新当前
                  // 如果删完了
                  if (!this.keywords.length) {  // 取消删除状态
                    this.isDeleting = false
                  }
                })
            }
          }
          .padding({ left: 12, right: 12 })
          .height(32)
          .backgroundColor('#f3f4f5')
          .borderRadius(16)
          .margin({ right: 16, top: 16 })
          .onClick(() => {
            if (!this.isDeleting) {
              // 非编辑态才可点击搜索
              this.onSearch(keyword)
            }
          })
        })
      } else {
        Text('暂无搜索记录')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(16)
          .fontColor($r('app.color.common_gray_01'))
      }
    }
    .padding(16)
  }
}