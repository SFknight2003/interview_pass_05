import { HmTag, QuestionItemComp, QuestionListComp } from "../../components"

export interface QuestionType {
  id: number
  name: string
  displayNewestFlag: 0 | 1
}

@Component
export struct HomeCategory {
  @State questionTypeList: QuestionType[] = mockData
  @State activeIndex: number = 0
  @Builder
  TabBarBuilder(item:QuestionType, index:number){
    Row(){
      Stack({alignContent:Alignment.Bottom}){    // 堆叠底部
        Text(item.name)
          .fontColor(this.activeIndex === index ? $r('app.color.black') : $r('app.color.common_gray_01'))
          .height(36)
          .fontSize(16)
        Row()
          .height(2)
          .width(this.activeIndex === index ? 20 : 0)
          .backgroundColor($r('app.color.black'))
          .animation({duration: this.activeIndex === index ? 300 : 0})   // 切换动画过度
      }
      if(item.displayNewestFlag === 1){
        Image($r('app.media.ic_home_new')).width(32).height(14)
          .objectFit(ImageFit.Contain)
          .margin({
            left:4
          })
      }
    }
    .margin({
      left:8,
      right:8
    })
  }



  build() {
    Tabs() {
      // TODO 试题列表
      ForEach(this.questionTypeList,(item:QuestionType,index)=>{
        TabContent(){
          // TODO: 列表代码
          Column(){
            /*
               测试代码
            ForEach(Array(10).fill(1),()=>{
              QuestionItemComp({
                item: {
                  id: '100',
                  stem: '请说下ArkUI的容器组件有哪些？',
                  difficulty: 3,
                  likeCount: 23,
                  views: 423,
                  readFlag: 1
                }
              })
             })
             */
            QuestionListComp()
              .layoutWeight(1)
          }
        }
        .tabBar(this.TabBarBuilder(item,index))
      })
    }
    .barMode(BarMode.Scrollable)  // 文字内容占满 滑动
    .barHeight(58)
    .scrollable(false)  // 禁止手动滑动
    .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_border') }) // 分割线
    .onTabBarClick((index)=>{
      this.activeIndex = index
    })
  }
}

const mockData : QuestionType[] = [
  { id: 1, name: 'ArkTS', displayNewestFlag: 0 },
  { id: 2, name: 'ArkUI', displayNewestFlag: 1 },
  { id: 3, name: 'Hap', displayNewestFlag: 1 },
  { id: 4, name: 'Hsp', displayNewestFlag: 0 },
  { id: 5, name: 'Har', displayNewestFlag: 0 },
  { id: 6, name: 'Ability', displayNewestFlag: 0 },
  { id: 7, name: 'Stage', displayNewestFlag: 0 },
  { id: 8, name: 'Kit', displayNewestFlag: 0 }
]