import { window } from '@kit.ArkUI';
import { logger } from '.';
/**
 * @Description: 全屏工具
 */
class FullScreen {
  async enable() {
    try {
      const context = AppStorage.get<Context>('context')
      if (context) {  // 拿到上下文
        const win = await window.getLastWindow(context) // 获取当前窗口
        await win.setWindowLayoutFullScreen(true) // 设置全屏
        // 获取上下安全区并存储
        const topArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
        AppStorage.setOrCreate('topHeight', px2vp(topArea.topRect.height))    // 保存上下宽度大小
        const bottomArea =  win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
        AppStorage.setOrCreate('bottomHeight', px2vp(bottomArea.bottomRect.height))
      }
    } catch (e) {
      logger.error('FullScreen Error', JSON.stringify(e))
    }
  }
  async disable() {
    try {
      const context = AppStorage.get<Context>('context')
      if (context) {
        const win = await window.getLastWindow(context)
        await win.setWindowLayoutFullScreen(false)  // 关闭全屏
        AppStorage.setOrCreate('topHeight', 0)
        AppStorage.setOrCreate('bottomHeight', 0)
      }
    } catch (e) {
      logger.error('CloseFullScreen disable', JSON.stringify(e))
    }
  }
}
export const fullScreen = new FullScreen()