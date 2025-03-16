import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { fullScreen, logger } from '../commons/utils';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    logger.info('Ability onCreate');
    // 全局传入context上下文
    AppStorage.setOrCreate('context',this.context)
  }

  onDestroy(): void {
    logger.info('Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    logger.info('Ability onWindowStageCreate');

    // 开启沉浸式
    fullScreen.enable()

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        logger.error('Failed to load the content. Cause: ', JSON.stringify(err) ?? '');
        return;
      }
      logger.info('Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    logger.info('Ability onWindowStageDestroy');
  }

  onForeground(): void {
    logger.info('Ability onForeground');
  }

  onBackground(): void {
    logger.info('Ability onBackground');
  }
}
