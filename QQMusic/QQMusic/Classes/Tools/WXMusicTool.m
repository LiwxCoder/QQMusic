//
//  WXMusicTool.m
//  QQMusic
//
//  Created by 李伟雄 on 16/1/7.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "WXMusicTool.h"
#import "WXMusicItem.h"
#import <MJExtension.h>

@implementation WXMusicTool

#pragma mark - 静态变量
/** 所有音乐 */
static NSArray *_musicItems;
/** 当前播放的音乐 */
static WXMusicItem *_playingMusicItem;

/** 获取所有音乐模型,设置当前默认音乐 */
+ (void)initialize
{
    // 获取所有音乐模型
    _musicItems = [WXMusicItem mj_objectArrayWithFilename:@"Musics.plist"];
    // 设置当前默认音乐
    _playingMusicItem = _musicItems[1];
}

#pragma mark - 播放音乐操作
/** 获取所有的音乐 */
+ (NSArray *)musics
{
    return _musicItems;
}

/** 获取正在播放的音乐(默认) */
+ (WXMusicItem *)playingMusic
{
    return _playingMusicItem;
}

/** 设置播放的音乐 */
+ (void)setupMusic:(WXMusicItem *)music
{
    _playingMusicItem = music;
}

/** 获取上一首音乐 */
+ (WXMusicItem *)previous
{
    // 1.获取当前音乐的下标值
    NSInteger currentIndex = [_musicItems indexOfObject:_playingMusicItem];
    
    // 2.获取上一首音乐的下标值,判断是否越界
    NSInteger previousIndex = currentIndex - 1;
    if (previousIndex < 0) {
        previousIndex = _musicItems.count - 1;
    }
    
    // 3.获取上一首的音乐
    WXMusicItem *previousMusicItem = _musicItems[previousIndex];
    
    // 4.返回上一首音乐
    return previousMusicItem;
}

/** 获取下一首音乐 */
+ (WXMusicItem *)next
{
    // 1.获取当前音乐的下标值
    NSInteger currentIndex = [_musicItems indexOfObject:_playingMusicItem];
    
    // 2.获取下一首音乐的下标值,判断是否越界
    NSInteger nextIndex = currentIndex + 1;
    if (nextIndex >= _musicItems.count) {
        nextIndex = 0;
    }
    
    // 3.获取下一首的音乐
    WXMusicItem *nextMusicItem = _musicItems[nextIndex];
    
    // 4.返回下一首音乐
    return nextMusicItem;
}


@end
