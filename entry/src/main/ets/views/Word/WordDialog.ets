import { media } from "@kit.MediaKit"

@CustomDialog
export struct WordDialog {
  controller: CustomDialogController
  @Prop en: string = ''
  @Prop zh: string = ''
  avPlayer?: media.AVPlayer // 记录

  async aboutToAppear() {
    // 1、创建音乐播放器 占用内存
    const avPlayer = await media.createAVPlayer()
    // 设置媒体资源播放地址（播放源）
    // 2、设置媒体资源播放地址
    avPlayer.url = `https://dict.youdao.com/dictvoice?type=1&audio=${this.en}`
    // （附加设置 非必须）
    avPlayer.on('stateChange', (state)=>{ // 监听状态
      if(state === 'initialized'){
        // 3、准备
        avPlayer.prepare()
      } else if (state === 'prepared') {
        // 4、播放
        avPlayer.loop  = true // 循环播放
        avPlayer.play()
      }
    })
    this.avPlayer = avPlayer  // 引用传递
  }

  aboutToDisappear(): void {
    // 销毁：
    // 内存泄露：占用内存永远无法被释放
    if (this.avPlayer) {
      this.avPlayer.stop()
      this.avPlayer.release()
    }
  }

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Text(this.en)
          .fontSize(20)
          .fontColor($r('app.color.white'))
          .fontWeight(500)
        WordSoundComp()
      }
      Text(this.zh)
        .fontColor($r('app.color.white'))
    }
    .constraintSize({ minWidth: 175 })
    .padding({ left: 16, right: 16 })
    .height(90)
    .borderRadius(45)
    .backgroundColor('#8f000000')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct WordSoundComp {
  @State flag: boolean = false
  timerId?: number

  aboutToAppear(): void {
    this.timerId = setInterval(() => {
      this.flag = !this.flag
    }, 500) // 500ms闪烁
  }
  aboutToDisappear(): void {
    clearInterval(this.timerId)
  }
  build() {
    Image($r('sys.media.ohos_ic_public_sound'))
      .width(20)
      .aspectRatio(1)
      .fillColor(this.flag ? $r('app.color.common_green') : $r('app.color.white'))
  }
}