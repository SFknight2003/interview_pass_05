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