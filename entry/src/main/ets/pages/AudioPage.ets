import { abilityAccessCtrl } from '@kit.AbilityKit'
import { promptAction, router } from '@kit.ArkUI'
import { media } from '@kit.MediaKit'
import { fileIo } from '@kit.CoreFileKit'
import { logger } from '../common/utils'
import { relationalStore } from '@kit.ArkData'
import { AudioView } from '../views/Audio/AudioView'

@Entry
@Component
struct AudioPage {
  aboutToAppear(): void {
    this.checkPermission()  // 进入页面开始鉴权
  }

  /*
      async checkPermission(){
    // 有无权限
    const manager = abilityAccessCtrl.createAtManager() // 权限控制器
      // 第一次从用户申请权限
      // 先自动检测是否有权限，没有权限 弹窗给用户
    const result = await manager.requestPermissionsFromUser(getContext(),["ohos.permission.MICROPHONE"])
      // 遍历所有的已授权权限（只包含当前页面所检测的麦克风权限）
    const isPass = result.authResults.every((result)=>{
      return result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    })
    if(isPass){
      // 提示弹层，等权限弹层结束后弹
      promptAction.showToast({
        message:'第一次允许'
      })
    } else {
      // 告知用户弹层提示
      const confirm = await promptAction.showDialog({
        title: "温馨提示",
        message: "未授权使用麦克风将无法使用面试录音功能，是否前往设置？",
        buttons:[
          {text:"离开", color:$r('app.color.common_gray_01')},
          {text:"去授权", color:$r('app.color.black')},
        ]
      })
      if( confirm.index === 1){
        // 前往授权
        // 没有，二次弹层确认 打开设置（不再跳转系统页）
        // 权限设置中的权限申请
        const finalResult = await manager.requestPermissionOnSetting(getContext(),["ohos.permission.MICROPHONE"])
        const finalPass = finalResult.every((result)=>{
          return result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
        })
        if (finalPass){
          setTimeout(()=>{
            promptAction.showToast({
              message:'第二次允许'
            })
          }, 10 )
        } else {
          setTimeout(()=>{
            promptAction.showToast({
              message:'第二次不允许'
            })
          }, 10 )
        }
      } else {
        // 不授权，返回上一页
        router.back()
      }
    }
  }
   */

  // 权限检测
  async checkPermission(){
    // 有无权限
    const manager = abilityAccessCtrl.createAtManager() // 权限控制器
    // 第一次从用户申请权限
    // 先自动检测是否有权限，没有权限 弹窗给用户
    const result = await manager.requestPermissionsFromUser(getContext(),["ohos.permission.MICROPHONE"])
    // 遍历所有的已授权权限（只包含当前页面所检测的麦克风权限）
    const isPass = result.authResults.every((result)=>{
      return result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    })
    if(!isPass){
      // 告知用户弹层提示
      const confirm = await promptAction.showDialog({
        title: "温馨提示",
        message: "未授权使用麦克风将无法使用面试录音功能，是否前往设置？",
        buttons:[
          {text:"离开", color:$r('app.color.common_gray_01')},
          {text:"去授权", color:$r('app.color.black')},
        ]
      })
      if( confirm.index === 1){
        // 没有，二次弹层确认 打开设置（不再跳转系统页）
        // 权限设置中的权限申请
        const finalResult = await manager.requestPermissionOnSetting(getContext(),["ohos.permission.MICROPHONE"])
        const finalPass = finalResult.every((result)=>{
          return result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
        })
        if (finalPass){
          setTimeout(()=>{
            promptAction.showToast({
              message:'授权成功'
            })
          }, 10 )
        } else { router.back() }
      } else { router.back() }
    }
  }

  // 录音
  avRecorder?: media.AVRecorder
  // fd文件唯一标识
  fd?: number
  // 文件路径
  filePath?: string
  // 振幅计时器
  timer?: number
  @State maxAmplitude: number = 0

  // 录音开启
  async startRecord() {
    // 1. 准备一个文件接收录音
    const ctx = getContext(this)
    const filePath = ctx.filesDir + '/' + Date.now() + '.m4a' // 文件路径
    this.filePath = filePath
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE) // 打开文件向里面写值
    this.fd = file.fd // 文件唯一标识
    // 2. 准备录音配置对象
    const config: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, // 录音源类型
      url: `fd://${file.fd}`,  // 要求为fd协议
      profile: {  // 下面都为音源默认值
        audioBitrate: 100000, // 音频比特率
        audioChannels: 1, // 音频声道数
        audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前只支持aac
        audioSampleRate: 48000, // 音频采样率
        fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前只支持m4a
      },
    }
    // 3. 开始录制
    const avRecorder = await media.createAVRecorder()  // 创建播放器
    await avRecorder.prepare(config)  // 配置参数
    await avRecorder.start()
    this.avRecorder = avRecorder  // 接收播放器
    // 4. 每100ms获取一下声音振幅
    this.timer = setInterval(async () => {
      this.maxAmplitude = await avRecorder.getAudioCapturerMaxAmplitude() // 获取音轨最大值
      logger.debug('startRecord', this.maxAmplitude.toString())
    }, 100)
  }

  // 录音关闭
  async stopRecord() {
    // 先判断是否有音乐播放器
    if (this.avRecorder) {
      await this.avRecorder.stop()
      await this.avRecorder.release() // 释放资源
      // 文件写入buffer是录音机实现的
      fileIo.closeSync(this.fd)
      // stopRecord 清理定时器
      clearInterval(this.timer)
      this.maxAmplitude = 0
    }
  }

  avPlayer?:media.AVPlayer
  // 播放录音
  async playRecord(){
    // 如果正在播放结束 内存泄露：占用内存永远无法被释放
    if (this.avPlayer) {
      this.avPlayer.stop()
      this.avPlayer.release()
      return
    } else {
      // 播放录音
      const file = fileIo.openSync(this.filePath, fileIo.OpenMode.READ_ONLY)  // 获取文件
      const avPlayer = await media.createAVPlayer() // 创建播放器
      avPlayer.url = `fd://${file.fd}` // 播放地址
      // 状态判断
      avPlayer.on('stateChange', (state) => {
        if (state === 'initialized') {
          avPlayer.prepare()
        } else if (state === 'prepared') {
          avPlayer.loop = true
          avPlayer.play()
        }
      })
    }
  }

  // 创建数据库
  store?: relationalStore.RdbStore
  tableName = 'userInfo'
  @State userList:UserInfo[] = []
  @State total:number = 0
  async createStore () {
    //得到数据库实例
    const store = await relationalStore.getRdbStore(getContext(this), {
      name: 'interview.db',
      securityLevel: relationalStore.SecurityLevel.S1 // 安全级别最轻
    })
    //建表
    store.executeSql(`
        CREATE TABLE IF NOT EXISTS ${this.tableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          age INTEGER NOT NULL
        )
      `)
    this.store = store
  }

  // 删除数据库
  deleteStore () {
    relationalStore.deleteRdbStore(getContext(this), {
      name: 'interview.db',
      securityLevel: relationalStore.SecurityLevel.S1
    })
  }

  build() {
    Column({space:5}) {
      // AudioBoComp({ maxAmplitude: this.maxAmplitude })  // 振幅

      AudioView()

      // Button('录音').onClick(()=>{
      //     this.startRecord()
      //   })
      // Button('停止录音').onClick(()=>{
      //   this.stopRecord()
      // })
      // Button('播放录音').onClick(()=>{
      //   this.playRecord()
      // })
      //
      // Button('创建数据库').onClick(()=>{
      //   this.createStore()
      // })
      // Button('添加').onClick(() => {
      //   this.store?.insert(this.tableName, {
      //     // id: null,  逐渐可以省略不写
      //     name: '测试' + Math.random(),
      //     age: Math.floor(Math.random()*100)
      //   })
      //   promptAction.showToast({
      //     message:"插入成功"
      //   })
      // })
      // Button('查询总条数').onClick(async () => {
      //     const predicates = new relationalStore.RdbPredicates(this.tableName)  // 拿到字典
      //     const resultSet = await this.store?.query(predicates)
      //     this.total = resultSet?.rowCount || 0
      //   })
      // Text('总条数' + this.total)
      // Button('查询所有数据').onClick(async () => {
      //     const predicates = new relationalStore.RdbPredicates(this.tableName)
      //     const resultSet = await this.store?.query(predicates)
      //     const list: UserInfo[] = []
      //     while (resultSet?.goToNextRow()) {
      //       list.push({
      //         id: resultSet.getLong(resultSet.getColumnIndex('id')),
      //         name: resultSet.getString(resultSet.getColumnIndex('name')),
      //         age: resultSet.getLong(resultSet.getColumnIndex('age')),
      //       })
      //     }
      //     resultSet?.close()
      //     this.userList = list
      //   })
      // Text(JSON.stringify(this.userList))
      // Button('修改第一条').onClick(() => {
      //   const item = this.userList[0]
      //   item.name = 'xxxx测试' + Math.random()
      //   const predicates = new relationalStore.RdbPredicates(this.tableName)
      //   predicates.equalTo('id', item.id)
      //   this.store?.updateSync(item, predicates)
      // })
      // Button('删除第一条').onClick(() => {
      //   const item = this.userList[0]
      //   const predicates = new relationalStore.RdbPredicates(this.tableName)
      //   predicates.equalTo('id', item.id)
      //   this.store?.deleteSync(predicates)
      // })
      // Button('删除数据库').onClick(() => { this.deleteStore() })
    }
    .height('100%')
    .width('100%')
    .padding({
      top: 50
    })
  }
}


interface UserInfo extends relationalStore.ValuesBucket{
  id : number,
  name : string,
  age : number,
}