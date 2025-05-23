// 覆盖到各个叶敏的数据类型
  // 只是对字面量对象进行限制（如果有对象了，不用再创建对象，就是用interface）
  // class适合new对象（通过构造函数定义不同的对象），包括objectLink限制时使用， 其他情况可以用interface
export interface QuestionItem {
  id: string;
  /* 题干 */
  stem: string;
  /* 难度 */
  difficulty: number;
  /* 点赞数 */
  likeCount: number;
  /* 浏览数 */
  views: number;
  /* 是否已看 */
  readFlag: 0 | 1;
}

// 详情数据
export interface QuestionDetail extends QuestionItem {  // 继承QuestionItem再添加字段
  /* 答案 */
  answer: string
  /* 是否收藏 */
  collectFlag: 0 | 1
  /* 是否点赞 */
  likeFlag: 0 | 1
  /* 所属模块 */
  stage: string[]
}

export interface QuestionOptParams {
  id: string
  /* 0 试题  2 面经 */
  type: 0 | 1
  /* 1 点赞  2 收藏 */
  optType: 1 | 2
}

export interface QuestionPageParams {
  item: QuestionItem,
  list: QuestionItem[]
}

// 响应结果
export interface PageData<T> {
  total: number
  pageTotal: number
  rows: T[]
}

// 难度排序
export enum SortType {
  Default = 0,
  DifficultyLow = 10,
  DifficultyHigh = 11,
  ViewLow = 20,
  ViewHigh = 21,
  Commend = 30    // 推荐
}

// 请求参数
export interface QuestionListParams {
  type: number
  questionBankType: 9 | 10
  sort?: SortType
  page?: number
  pageSize?: number
  keyword?:string // 用于搜索
}

export interface User {
  id: string
  username: string
  avatar: string
  token: string
  nickName?: string
  // 学习时长
  totalTime?: number
  // 打卡次数
  clockinNumbers?: number
}

export interface LoginParams {
  username:string
  password:string
}

// 埋点
export interface TimeItem {
  questionId: string
  startTime: number
  endTime: number
}

// 打卡数据
  //响应参数类型
export interface ClockInItem {
  id: string,
  createdAt: string
}
  // 响应结果
export interface ClockInfo {
  flag: boolean
  clockinNumbers: number
  totalClockinNumber: number
  clockins: ClockInItem[]
}
  //请求参数类型
export interface ClockInfoParams {
  year: string,
  month: string
}

// 累计学时
// 学习时间
export interface StudyTimeItem {
  id: string
  name: string
  total: number
  done: number  // 已完成
  undone: number  // 未完成
}
export interface StudyTimeCate {
  type: string,
  list: StudyTimeItem[]
}
export interface StudyTimeData {
  totalTime: number,
  studyData: StudyTimeCate[]
}

// 单词
export interface WordItem{
  en: string,
  zh: string,
  code: string
}
// 有一些类型，不是对象也可也用type声明类型
  // 起别名
export type Words = Record<string,WordItem[]>