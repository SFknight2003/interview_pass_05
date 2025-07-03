import { auth, http, logger, UserStoreKey } from '../common/utils'
import { User } from '../models'
import { HmLoadingDialog, HmNavBar } from '../common/components'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { FormData } from '@ohos/axios'
import fileIo from '@ohos.file.fs'
import { image } from '@kit.ImageKit'

@Entry
@Component
struct ProfilePage {
  @StorageProp(UserStoreKey) user: User = {} as User
  dialog: CustomDialogController = new CustomDialogController({
    builder: HmLoadingDialog({ message: '更新中...' }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  // 修改头像和昵称方法
  async updateNickName(){
    await http.request<null,User>({
      url:'hm/userInfo/profile',
      method: 'post',
      data:{
        nickName: this.user.nickName
      } as User
    })
    promptAction.showToast({
      message:'昵称成功'
    })
    auth.setUser(this.user)
  }

  // 修改头像
  async updateAvatar(){
    // 1、唤起相册选择 - 选一张图
        // picker.PhotoViewPicker 已淘汰
    const option = new photoAccessHelper.PhotoSelectOptions()
    option.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE // 选择类型
    option.maxSelectNumber = 1 // 图片数量
    const picker = new photoAccessHelper.PhotoViewPicker()
    const result = await picker.select(option) // 唤起选择
    const uri = result.photoUris[0] // 图片地址
    this.dialog.open()

    // 2、存放到沙箱 -  cache - internal
      // 普通存放（无压缩）
    // const file = fileIo.openSync(uri,fileIo.OpenMode.READ_ONLY) // 打开图片
    // fileIo.copyFileSync(file.fd, getContext().cacheDir+'/'+file.name)  // 拷贝图片
    // fileIo.closeSync(file.fd)  // 关闭

    // 压缩存放
      // 普通压缩
    // const originFile = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
    // const imageSource = image.createImageSource(originFile.fd);  // 创建图片源
    // const imagePacker = image.createImagePacker()   // 创建打包器
    // const arrayBuffer = await imagePacker.packing(imageSource, { format: "image/jpeg", quality: 70})  // 压缩
    // const newFilePath = getContext(this).cacheDir + '/' + Date.now() + '.jpg'
    // const newFile = fileIo.openSync(newFilePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE) // 创建新文件
    // fileIo.writeSync(newFile.fd, arrayBuffer) // 写入保存
    // logger.debug('size', fileIo.statSync(newFile.fd).size.toString())
    // fileIo.closeSync(newFile.fd)

      // 压缩图片（pixelMap）
    const originFile = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
    const imageSource = image.createImageSource(originFile.fd);  // 创建图片源
    const pixelMap = await imageSource.createPixelMap();  // 读取图片为PixelMap
    const packer = image.createImagePacker()
    const buffer = await packer.packing(pixelMap, { format:'image/jpeg', quality:98 })  // 压缩
    const newFilePath = getContext(this).cacheDir + '/' + Date.now() + '.jpg'
    let newFile = fileIo.openSync(newFilePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.writeSync(newFile.fd, buffer);
    fileIo.closeSync(newFile.fd)
    pixelMap.release();

    // 如何限制大小？
    // fileIo.statSync(file).size
    // 4、发送图片给后台
    const formData = new FormData();
    // formData.append('file','internal://cache/' + file.name);
    formData.append('file', `internal://cache/${newFile.name}`) // 压缩版

    await http.request<string>({
      url: 'hm/userInfo/avatar',
      method: 'post',
      data: formData,
      context: getContext(),
      headers:{
        'Content-Type':'multipart/form-data'
      }
    });
    // url是上传更新完成的地址  重新获取头像
    const user = await http.request<User,User>({
      url:'hm/userInfo'
    })
    // 当前展示的更新
    this.user.avatar = user.avatar;
    // 本地存储更新
    auth.setUser(this.user)
    promptAction.showToast({
      message:'修改成功',
    })
    this.dialog.close();
  }

  build() {
    Column() {
      HmNavBar({ title: '编辑资料', showRightIcon: false })
      List() {
        ListItem() {
          Row() {
            Text('头像')
            Image(this.user.avatar || $r('app.media.ic_mine_avatar'))
              .alt($r('app.media.ic_mine_avatar'))
              .width(40)
              .aspectRatio(1)
              .borderRadius(20)
              .border({ width: 0.5, color: $r('app.color.common_gray_border') })
              .onClick(() => {
                // 更新头像
                this.updateAvatar()
              })
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.SpaceBetween)
        }

        ListItem() {
          Row() {
            Text('昵称')
            TextInput({ text: this.user.username })
              .fontColor($r('app.color.common_gray_03'))
              .textAlign(TextAlign.End)
              .layoutWeight(1)
              .padding(0)
              .height(60)
              .backgroundColor($r('app.color.white'))
              .borderRadius(0)
              .onChange((value) => this.user.username = value)  // 数据绑定修改
              .onSubmit(() => {
                // 更新昵称
                this.updateNickName()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 35,
        right: 35,
        top: 15,
        bottom: 15
      })
      .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_bg') })
    }
  }
}