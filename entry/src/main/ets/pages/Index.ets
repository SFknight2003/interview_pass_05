import { statusBar } from '../commons/utils';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Text('123')
      Button('浅色').onClick(()=>{
        statusBar.setLightBar()
      })
      Button('深').onClick(()=>{
        statusBar.setDarkBar()
      })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Color.Pink)
  }
}