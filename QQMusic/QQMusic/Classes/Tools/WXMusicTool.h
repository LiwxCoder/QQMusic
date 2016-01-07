//
//  WXMusicTool.h
//  QQMusic
//
//  Created by 李伟雄 on 16/1/7.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WXMusicItem;

@interface WXMusicTool : NSObject

/** 获取所有的音乐 */
+ (NSArray *)musics;

/** 获取正在播放的音乐(默认) */
+ (WXMusicItem *)playingMusic;

/** 设置播放的音乐 */
+ (void)setupMusic:(WXMusicItem *)music;

/** 获取上一首音乐 */
+ (WXMusicItem *)previous;

/** 获取下一首音乐 */
+ (WXMusicItem *)next;
@end
