import { QuestionDetail, User } from "../../../models"
import { UserStoreKey } from "../../utils"
import { componentSnapshot, promptAction } from "@kit.ArkUI"
import { image } from "@kit.ImageKit"
import { fileIo, fileUri } from "@kit.CoreFileKit"
import { photoAccessHelper } from "@kit.MediaLibraryKit"
import { JSON } from "@kit.ArkTS"

@CustomDialog
export struct QuestionShareDialog {
  @Prop item: QuestionDetail = {} as QuestionDetail
  @StorageProp(UserStoreKey) user: User = {} as User
  controller: CustomDialogController

  // 组件截图
  async saveImage(){
    // 组件截图
    const pixelMap = await componentSnapshot.get('share')
    // 2、图片数据处理
    //    压缩图片
    const packer = image.createImagePacker()
    // 压缩后的数据
    const buffer = await packer.packing(pixelMap, { format:'image/jpeg', quality:98 })  // 参数：文件，格式 压缩质量
    // 存入沙箱
    const ctx = getContext(this)
    const filePath = ctx.cacheDir + '/' + Date.now() + '.jpeg' // 存放路径
    // 文件创建 -> 打开路径，（有 打开，没有 创建再打开）
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)  // 参数：路径，模式（创建|读写）
    // 给文件写入buffer
    fileIo.writeSync(file.fd, buffer)
    // 关闭文件
    fileIo.closeSync(file.fd)

    // 存入相册
      // 1、创建工具
      // 2、准备图片地址
    const assetChangeRequest = photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(ctx, filePath)  // 直接传入沙箱地址
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(ctx)
      // 3、存储请求发起
      // 4、开启保存
    await phAccessHelper.applyChanges(assetChangeRequest)
    // 关闭弹层
    this.controller.close()

    promptAction.showToast({ message: '保存成功' })
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // 分享的组件
      Column({ space: 20 }) {
        Image($r('app.media.ic_interview_logo'))
          .width(40)
          .height(40)
        Text('面试通，搞定企业面试题')
        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.common_gray_border'))
        Text('大厂面试题：' + this.item.stem)
          .fontSize(12)
          .maxLines(2)
          .fontWeight(600)
          .width('100%')
          .lineHeight(24)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        // 二维码
        QRCode(this.item.id)  // 传入试题id 用于扫码跳转题目
          .width(160)
          .height(160)
        Text('扫码查看答案')
          .fontSize(12)
          .alignSelf(ItemAlign.Center)
        Blank()
        Text('分享来自：' + this.user.nickName || this.user.username)
          .fontSize(12)
      }
      .id('share')  // 组件id
      .padding(20)
      .alignItems(HorizontalAlign.Start)
      .width(300)
      .height(500)
      .backgroundColor($r('app.color.white'))

      Row() {
        SaveButton({
          icon: SaveIconStyle.FULL_FILLED,
          text: SaveDescription.SAVE_IMAGE,
          buttonType: ButtonType.Normal
        })
          .fontColor($r('app.color.white'))
          .fontSize(14)
          .padding(12)
          .backgroundColor($r('app.color.common_main_color'))
          .onClick((_event:ClickEvent, result:SaveButtonOnClickResult) => {
            if (result === SaveButtonOnClickResult.SUCCESS) { // 检测安全环境，成功即执行
              try{
                this.saveImage()
              } catch (error) {
                console.error("error is " + JSON.stringify(error))
              }
            }
          })
      }
      .borderRadius({ topLeft: 8 })
      .clip(true)
    }
    .borderRadius(8)
    .clip(true)
  }
}