//
//  WXAudioTool.h
//  23-播放音效(封装工具类)
//
//  Created by 李伟雄 on 16/1/7.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVAudioPlayer;

@interface WXAudioTool : NSObject

#pragma mark - 播放短音乐API(AVAudioPlayer)
/** 播放音乐 */
+ (AVAudioPlayer *)playMusicWithMusicName:(NSString *)musicName;

/** 暂停音乐 */
+ (void)pauseMusicWithMusicName:(NSString *)musicName;

/** 停止音乐 */
+ (void)stopMusicWithMusicName:(NSString *)musicName;


#pragma mark - 播放音效API(SystemSoundID)
/** 播放音效 */
+ (void)playSoundWithSoundName:(NSString *)soundName;
@end
