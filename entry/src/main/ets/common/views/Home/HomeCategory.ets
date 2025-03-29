import { HmSkeleton, HmSkeletonItem, HmTag, QuestionItemComp, QuestionListComp } from "../../components"
import { http, UserStoreKey } from "../../utils"
import { Filter, promptAction } from "@kit.ArkUI"
import { QuestionItem, SortType } from "../../../models"

export interface QuestionType {
  id: number
  name: string
  displayNewestFlag: 0 | 1
}

@Component
export struct HomeCategory {
  controller: TabsController = new TabsController()
  @State questionTypeList: QuestionType[] = []
  // 当前分类
  @State activeIndex: number = 0
  // 当前排序
  @State sort:SortType = SortType.Default
  // 排序索引
  @State filterIndex:number = 0
  @State isShow:boolean = false
  @State filterSort:SortType = SortType.Default
  @State loading : boolean = false
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
  // 筛选模态
  @Builder
  FilterSheetBuilder() {
    Column() {
      Row() {
        Text('重置')
          .fontSize(16)
          .fontWeight(500)
          .fontColor($r('app.color.common_gray_03'))
          .onClick(()=>{
            this.sort = SortType.Default
            this.filterIndex = 0
          })
        Text('筛选题目')
          .layoutWeight(1)
          .fontSize(18)
          .fontWeight(500)
          .fontColor($r('app.color.black'))
          .textAlign(TextAlign.Center)
        Text('完成')
          .fontWeight(500)
          .fontSize(16)
          .fontColor($r('app.color.common_main_color'))
          .onClick(()=>{
            this.isShow = false
            this.activeIndex = this.filterIndex   // 将当前选择的index 同步到tab栏
            this.controller.changeIndex(this.activeIndex)
            this.sort = this.filterSort
          })
      }
      .margin({ bottom: 4, top: 4 })
      Text('题目排序')
        .textTitle()
      // TODO 筛选按钮
      Flex(){
        FilterButton({
          text:'默认',
          isSelected:this.filterSort === SortType.Default,
          sort:this.filterSort
        }).onClick(()=>{
          this.filterSort = SortType.Default
        })
        FilterButton({
          text:'浏览量',
          isSort:true,
          isSelected:this.filterSort === SortType.ViewLow || this.filterSort === SortType.ViewHigh,
          sort:this.filterSort
        }).onClick(()=>{
          if(this.filterSort === SortType.ViewLow){
            this.filterSort = SortType.ViewHigh
          } else {
            this.filterSort = SortType.ViewLow
          }
        })
        FilterButton({
          text:'难度',
          isSort:true,
          isSelected:this.filterSort === SortType.DifficultyLow || this.filterSort === SortType.DifficultyHigh,
          sort:this.filterSort
        }).onClick(()=>{
          if(this.filterSort === SortType.DifficultyLow){
            this.filterSort = SortType.DifficultyHigh
          } else {
            this.filterSort = SortType.DifficultyLow
          }
        })
        FilterButton({
          text:'推荐',
          isSelected:this.filterSort === SortType.Commend,
          sort:this.filterSort
        }).onClick(()=>{
          this.filterSort = SortType.Commend
        })
      }
      Text('选择分类')
        .textTitle()
      // TODO 筛选按钮
      Flex({ wrap:FlexWrap.Wrap }){ // 换行
        ForEach(this.questionTypeList,(item:QuestionType, i)=>{ // i是索引
          FilterButton({
            text:item.name,
            isNew:item.displayNewestFlag === 1,
            isSelected:this.filterIndex === i   // 将tabs中选中的分类 和filterButton中的进行对比
          }).onClick(()=>{
            this.filterIndex = i
          })
        })
      }
    }
    .padding(16)
    .backgroundColor($r('app.color.white'))
    .height('100%')
  }
  // 骨架框
  @Builder
  HmSkeleton() {
    Column() {
      Row({ space: 16 }) {
        HmSkeletonItem({ widthValue: 60 })
        HmSkeletonItem({ widthValue: 100 })
        HmSkeletonItem({ widthValue: 80 })
        HmSkeletonItem({ widthValue: 40 })
      }
      .height(44)
      .width('100%')
      ForEach([1, 2, 3, 4, 5, 6], () => {
        Column({ space: 10 }) {
          HmSkeletonItem({ widthValue: '90%' })
          HmSkeletonItem({ widthValue: '45%' })
        }
        .height(80)
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
      })
    }
    .padding({ left: 16, right: 16 })
  }
  async getQuestionTypeList(){
    this.loading = true
    const res = await http.request<QuestionType[],string>({
      url: 'hm/question/type',
      method: 'get' // 请求类型，不写默认get
    })
    this.questionTypeList = res
    // setTimeout(()=>{
    //   this.loading = false
    // },15000)
    this.loading = false
  }
  aboutToAppear(){
    // http是自己的工具
    // request是自己封装的方法
    // <QuestionType[]>是响应结果的类型
    // string是请求参数的类型
    this.getQuestionTypeList()
    // 订阅 - 保证自己能更新
    // 接收 - 线程内 - eventhub
    getContext().eventHub.on(UserStoreKey,()=>{
      // 监听到需要做什么
      this.getQuestionTypeList()
    })
  }

  build() {
    if (this.loading) {
      this.HmSkeleton()
    } else {
      Stack({alignContent:Alignment.TopEnd}){   // 堆叠右上角
        Tabs({ controller: this.controller }) {
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
                QuestionListComp({
                  typeId : item.id,
                  sort : this.sort,
                  activeIndex : this.activeIndex,
                  index : index
                })
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

        // 和 Tabs 同级，外面 Stack 组件，左上角对齐 Stack({ alignContent: Alignment.TopEnd }) {}
        Row() {
          Image($r('app.media.ic_home_filter'))
            .width(24)
            .aspectRatio(1)
        }
        .width(56)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .linearGradient({ angle: 90, colors: [['#00FFFFFF', 0], ['#FFFFFF', 0.285]] })
        .margin({
          top : 5
        })
        // 模态层
        .bindSheet($$this.isShow, this.FilterSheetBuilder(), {
          showClose: false,   // 关闭按钮
          height: 400
        })
        .onClick(() => {
          this.isShow = true
        })
      }
    }
  }
}

@Extend(Text)
function textTitle() {
  .fontSize(14)
  .fontWeight(500)
  .fontColor($r('app.color.black'))
  .width('100%')
  .margin({ top: 20 })
}

// 封装按钮组件
@Component
struct FilterButton {
  text:string = '默认'
  isSort:boolean = false
  isNew:boolean = false
  @Prop isSelected:boolean = false
  // 排序模式
  @Prop sort: SortType = SortType.Default
  build() {
    Row(){
      Text(this.text)
        .fontSize(12)
        .fontColor(this.isSelected ? $r('app.color.common_main_color') : $r('app.color.black'))
      if (this.isNew) {
        Image($r('app.media.ic_home_new'))
          .width(32)
          .height(14)
          .objectFit(ImageFit.Contain)
          .position({ right: -26, top: -7 })    // 定位到右上角
      }
      if (this.isSort) {
        Column() {
          Image($r('sys.media.ohos_ic_public_arrow_up'))
            .size({ width: 12, height: 6 })
            .fillColor(this.isSelected && this.sort%2 === 0 ? $r('app.color.common_main_color') : $r('app.color.black')) // 余数为0 升序
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .size({ width: 12, height: 6 })
            .fillColor(this.isSelected && this.sort%2 === 1 ? $r('app.color.common_main_color') : $r('app.color.black')) // 余数为1 降序
        }
        .margin({ top: -0.5, left: 2 })
      }
    }
    .height(30)
    .padding({ left: 10, right: 10 })
    .backgroundColor($r('app.color.common_gray_bg'))
    .borderRadius(4)
    .margin({ top: 12, right: this.isNew ? 26 : 10 })
  }
}

// const mockData : QuestionType[] = [
//   { id: 1, name: 'ArkTS', displayNewestFlag: 0 },
//   { id: 2, name: 'ArkUI', displayNewestFlag: 1 },
//   { id: 3, name: 'Hap', displayNewestFlag: 1 },
//   { id: 4, name: 'Hsp', displayNewestFlag: 0 },
//   { id: 5, name: 'Har', displayNewestFlag: 0 },
//   { id: 6, name: 'Ability', displayNewestFlag: 0 },
//   { id: 7, name: 'Stage', displayNewestFlag: 0 },
//   { id: 8, name: 'Kit', displayNewestFlag: 0 }
// ]