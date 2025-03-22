@Component
export struct HmSkeleton {
  @Builder
  defaultBuilder(){
  }
  @BuilderParam
  defaultParam:() => void = this.defaultBuilder
  @State opacityValue : number = 1
  build() {
    Column({space:6}){
      // 占位结构
      this.defaultParam()
    }
    .opacity(this.opacityValue)  // 透明度
    .animation({
      duration: 600,
      playMode: PlayMode.Alternate,
      iterations: -1,
      curve: Curve.EaseInOut
    })
    .onAppear(()=>{
      this.opacityValue = 0.5
    })
  }
}