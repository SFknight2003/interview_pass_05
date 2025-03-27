import { HomePage } from './HomePage';
import { ProjectPage } from './ProjectPage';
import { InterviewPage } from './InterviewPage';
import { MinePage } from './MinePage';
import { auth } from '../common/utils';

/**
 * @Description: 主框架页面
 */

// 进行持久化声明
auth.initUser()

// 数据定义
interface TabItems{
  icon:Resource,
  activeIcon:Resource,
  name: string
}

@Entry
@Component
struct Index {
  @StorageLink('topHeight') topHeight: number = 0
  @StorageLink('bottomHeight') bottomHeight: number = 0
  @State
  tabList:TabItems[] = [
    {
      icon:$r('app.media.tabbar_home'),
      activeIcon:$r('app.media.tabbar_home_fill'),
      name:'首页'
    },
    {
      icon:$r('app.media.tabbar_project'),
      activeIcon:$r('app.media.tabbar_project_fill'),
      name:'项目'
    },
    {
      icon:$r('app.media.tabbar_interview'),
      activeIcon:$r('app.media.tabbar_interview_fill'),
      name:'面经'
    },
    {
      icon:$r('app.media.tabbar_mine'),
      activeIcon:$r('app.media.tabbar_mine_fill'),
      name:'我的'
    }
  ]
  @State activeIndex:number = 0
  @Builder
  TabBarBuilder(item:TabItems, index:number){
    Column(){
      Image(this.activeIndex === index ? item.activeIcon : item.icon)
        .width(24)
        .aspectRatio(1)
      Text(item.name)
        .fontSize(12)
        .fontColor(this.activeIndex === index ? $r('app.color.black') : $r('app.color.common_gray_01'))
    }
  }

  build() {
    Column() {
      Tabs(){
        ForEach(this.tabList,(item:TabItems,index:number)=>{
          TabContent(){
            if ( index === 0 ) {
              HomePage()
            } else if (index === 1) {
              ProjectPage()
            } else if (index === 2) {
              InterviewPage()
            } else if (index === 3) {
              MinePage()
            }
          }.tabBar(this.TabBarBuilder(item, index))
        })
      }
      .barPosition(BarPosition.End)
      .divider({strokeWidth:.5, color:$r('app.color.common_gray_border')})
      // 遍历的列表index赋值给tabIndex
      .onTabBarClick((index)=>{
        this.activeIndex = index
      })
      .scrollable(false)  // 关闭滑动切换
      .margin({
        bottom: this.bottomHeight   // 避免页面导航栏颜色不一致，添加组件底部外间距
      })
    }
    .height('100%')
    .width('100%')

  }
}