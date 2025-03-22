/**
 * @Description: 状态标签
 */
interface HcTagInfo{
  text: string
  color: ResourceColor
}

// 描述tag标签的配置信息对象
const infoMap:Record<number,HcTagInfo> = {
  1:{text:'简单',color:$r('app.color.common_green')},
  2:{text:'简单',color:$r('app.color.common_green')},
  3:{text:'一般',color:$r('app.color.common_blue')},
  4:{text:'一般',color:$r('app.color.common_blue')},
  5:{text:'困难',color:$r('app.color.common_main_color')},
}

@Component
export struct HmTag {
  // 1-2 简单 - 文字，颜色
  // 3-4 一般
  // 5 困难
  @Prop
  difficulty:number = 1
  // 自定义文字内容+颜色
  @Prop
  text : string = ''
  @Prop
  color : ResourceColor = ''

  build() {
    Text(this.text || infoMap[this.difficulty].text)
      .fontColor(this.color || infoMap[this.difficulty].color)
      .fontSize(10)
      .padding({
        left: 6,
        right: 6
      })
      .height(18)
      .borderRadius(2)
      .textAlign(TextAlign.Center)
      .constraintSize({ // 自适应尺寸
        minWidth: 34
      })
      .backgroundColor($r('app.color.common_gray_bg'))
  }
}