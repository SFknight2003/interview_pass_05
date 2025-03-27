import { User } from '../../models'

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
}

export const auth = new Auth()