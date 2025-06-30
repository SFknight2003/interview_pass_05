import { HmNavBar } from '../../common/components/HmNavBar'
import { auth } from '../../common/utils'
import { audioDB, InterviewAudioItem } from '../../common/utils/AudioDB'
import { AudioItemComp } from './AudioItemComp'
import { AudioRecordComp } from './AudioRecord'

@Component
export struct AudioView {
  @State list: InterviewAudioItem[] = []
  aboutToAppear(): void {
    this.updateList()
    getContext().eventHub.on('updateRecordList',()=>{
      // 更新列表
      this.updateList()
    })
  }

  async updateList(){
    const userId = auth.getUser().id
    this.list = await audioDB.query(userId)
  }

  build() {
    Column() {
      HmNavBar({ title: '面试录音', showRightIcon: false })
      Column() {
        List() {
          ForEach(this.list, (item: InterviewAudioItem) => {
            ListItem() {
              AudioItemComp({
                item
              })
                .onClick(()=>{  // 播放录音

                })
            }
          })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .layoutWeight(1)
      // 录音组件
      AudioRecordComp()
    }
    .width('100%')
    .height('100%')
  }
}