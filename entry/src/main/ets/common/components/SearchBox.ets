@Component
export struct SearchBox {
  @Prop placeholder:string = '搜索题目'
  @Prop placeholderColor:ResourceColor = '#ff626262'
  @Prop boxWidth:number = 100
  @Prop boxHeight:number = 32
  @Prop boxBackColor:Resource = $r('app.color.common_gray_border')
  @Prop layoutWeightValue:number = 0

  build() {
    Row( { space:4 } ){
      // 搜索图标
      Image($r('app.media.ic_common_search'))
        .height(14)
        .aspectRatio(1)
      // 占位符
      Text(this.placeholder)
        .fontColor(this.placeholderColor)
        .fontSize(14)
    }
    .justifyContent(FlexAlign.Center) // 居中
    .width(this.boxWidth)
    .height(this.boxHeight)
    .layoutWeight(this.layoutWeightValue)  // 自适应会覆盖固定大小
    .borderRadius(this.boxHeight / 2)
    .backgroundColor(this.boxBackColor)
  }
}