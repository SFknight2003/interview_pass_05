import { QuestionItem } from "../../models"
import { HmTag } from "./"

@Component
export struct QuestionItemComp {
  @Require  // 必传值
  @Prop
  item:QuestionItem = {} as QuestionItem
  build() {
    Column({space:10}){
      Row(){
        HmTag({ difficulty : this.item.difficulty })  // 从item中拿取需要的字段
        Text( this.item.stem )
          .layoutWeight(1)
          .maxLines(1) // 最大行数
          .textOverflow({overflow:TextOverflow.Ellipsis}) // 溢出隐藏
          .fontSize(14)
      }
      RowSplit(){   // 直接分隔
        Text('点赞' + this.item.likeCount).grayText(true)
        Text('浏览' + this.item.views).grayText()
        if(this.item.readFlag === 1) {
          Text('已阅读').grayText()
        }
      }
    }
    .alignItems(HorizontalAlign.Start)  // 前置
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(80)
    .padding({
      left:16,
      right:16
    })
  }
}

@Extend(Text)
function grayText(isStart:boolean = false){
  .fontSize(12)
  .fontColor($r('app.color.common_gray_01'))
  .padding({ left: isStart ? 0 : 12 , right:12 })
}
