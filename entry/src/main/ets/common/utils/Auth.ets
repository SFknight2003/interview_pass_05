import { User } from '../../models'
import { router } from '@kit.ArkUI'
import { url } from '@kit.ArkTS'

export const UserStoreKey = 'UserStoreKey'

class Auth {
  //1.持久化声明
  initUser() {
    PersistentStorage.persistProp<User>(UserStoreKey, {} as User)
  }
  //2.获取用户
  getUser () {
    return AppStorage.get<User>(UserStoreKey) || {} as User
  }
  //3.写入用户
  setUser(user: User) {
    AppStorage.setOrCreate<User>(UserStoreKey, user)
  }
  /**
   * @Description: 鉴权
   * @about: 1、页面调换 2、功能操作
   */
  checkAuth(opt:router.RouterOptions | Function){
    // 判断有无权限
    const user = auth.getUser()
    if ( user.token ) {
      // 更多判断条件：权限点
      // if (user.permissionList.include(opt.url)) {}
      if( typeof opt === 'function' ){
        // 2、有token - 执行方法
        opt()
      } else {
        // 1、有token - 跳转页面
        router.pushUrl(opt)
      }
    } else {
      if ( typeof opt === 'function') {
        // 4、没登陆 - 执行方法
        router.pushUrl({
          url:'pages/LoginPage',
        })
      } else {
        // 3、没登录 - 跳转页面
        // opt才是用户需要跳转的页面
        // 鉴权不通过导向Login页面登录，登录完成继续返回opt
        const params = opt.params as Record<string,string> || {}
        params.return_url = opt.url // 将需要跳转的url也加入到params中
        router.pushUrl({
          url:'pages/LoginPage',
          params
          // 1、return_url : opt.url
          // 2、......{opt.params}
        })
      }
    }
  }
}

export const auth = new Auth()