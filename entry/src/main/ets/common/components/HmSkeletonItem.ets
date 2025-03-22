/**
 * @Description: 骨架屏单元
 */
@Component
export struct HmSkeletonItem {
  widthValue : Length = '100%'
  text:string = ''
  bgColor:ResourceColor = Color.Gray

  build() {
    Text(this.text)
      .width(this.widthValue)
      .height(16)
      .borderRadius(2)
      .backgroundColor(this.bgColor)
  }
}