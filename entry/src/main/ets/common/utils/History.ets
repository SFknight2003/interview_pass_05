import { preferences } from "@kit.ArkData";
import { Context } from "@ohos.abilityAccessCtrl";

class History {
  // 新建仓库
  store: preferences.Preferences | null = null
  historyKey: string = "history-key"
  getStore(){
    const cxt = AppStorage.get<Context>('context');
    if (!this.store) {
      this.store = preferences.getPreferencesSync(cxt, {name: "history-store"})
    }
    return this.store
  }
  // 存一条
  async setItem( value : string ){
    // key不能唯一，后面会有多个
        // value当key，如果重复加入不会重复
        // key如果固定，会覆盖。如果存数组也会有重复记录
    this.getStore().putSync(value, value)
    await this.getStore().flush()
  }
  // 删一条
  async deleteItem( value : string ){
    this.getStore().deleteSync(value)
    await this.getStore().flush()
  }
  // 删全部
  async clear(){
    this.getStore().clear()
    await this.getStore().flush()
  }
  // 拿全部
  getAll(){
    const obj = this.getStore().getAllSync()
    // obj对象：{key1:val1, key2:val2} -> [val1, val2]
    return Object.keys(obj)
  }
}

export const history = new History();