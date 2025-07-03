import { ConfigurationConstant } from '@kit.AbilityKit'

class Theme {
  themeKey:string = 'ThemeKey';
  // 1、持久化声明颜色主题
  initTheme() {
    PersistentStorage.persistProp<ConfigurationConstant.ColorMode>(this.themeKey,
      ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
    // 取出现在应用存储的颜色主题模式
    const theme = AppStorage.get<ConfigurationConstant.ColorMode>(this.themeKey)
    // 设置应用颜色主题模式
    this.setTheme(theme!)
  }

  // 2、主题设置
  setTheme(theme: ConfigurationConstant.ColorMode) {
    // 可能是页面点击设置
    AppStorage.set(this.themeKey, theme)
    // 应用及逆行设置
    getContext().getApplicationContext().setColorMode(theme)
  }

  // 3、跟随系统（不设置主题）
  notSet() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
  }

  // 4、暗色
  setDark() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
  }

  // 5、亮色
  setLight() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
  }
}

export const theme = new Theme()