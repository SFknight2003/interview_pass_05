import { window } from '@kit.ArkUI'
import { logger } from './Logger'
/**
 * @Description: 设置状态栏颜色工具类
 */
class StatusBar {
  // 深色 - 文字颜色
  async setDarkBar() {
    await this.setBar({ statusBarContentColor: '#000000' })
  }
  // 浅色
  async setLightBar() {
    await this.setBar({ statusBarContentColor: '#FFFFFF' })
  }
  // 自定义颜色
  async setBar(config: window.SystemBarProperties) {
    try {
      const context = AppStorage.get<Context>('context')
      if (context) {
        const win = await window.getLastWindow(context)
        // 核心，设置状态栏的方法
        await win.setWindowSystemBarProperties(config)
      }
    } catch (e) {
      logger.error('StatusBar setBar', JSON.stringify(e))
    }
  }
}
export const statusBar = new StatusBar()
