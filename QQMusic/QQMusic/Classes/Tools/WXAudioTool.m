//
//  WXAudioTool.m
//  23-播放音效(封装工具类)
//
//  Created by 李伟雄 on 16/1/7.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "WXAudioTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation WXAudioTool

// SINGLE: 创建一个可变字典缓存音乐,字典只需创建一次,可以在initialize类方法中创建
static NSMutableDictionary *_soundIDs;
// SINGLE: 创建音乐内存缓存,在initialize类方法中创建
static NSMutableDictionary *_players;

#pragma mark - 初始化设置
/** 创建内存缓存 */
+ (void)initialize {
    // 创建可变字典,用于存放播放音效SystemSoundID
    _soundIDs = [NSMutableDictionary dictionary];
    
    // 创建可变字典,用于存放音乐播放器AVAudioPlayer
    _players = [NSMutableDictionary dictionary];
}


#pragma mark - 播放音乐API(AVAudioPlayer)
/** 播放音乐 */
+ (AVAudioPlayer *)playMusicWithMusicName:(NSString *)musicName
{
    // 1.先从内存字典中获取播放器AVAudioPlayer
    AVAudioPlayer *player = _players[musicName];
    
    // 2.判断是否从内存获取到播放器,如果没有获取到,新建播放器
    if (player == nil) {
        // 2.1 获取音乐文件的url
        NSURL *url = [[NSBundle mainBundle] URLForResource:musicName withExtension:nil];
        if (url == nil) return nil;

        // 2.2 根据音频文件的url,创建播放器
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        // 2.3 保存到内存缓存_players
        [_players setObject:player forKey:musicName];
    }
    
    // SINGLE: 3.播放音乐
    [player play];
    
    return player;
}

/** 暂停音乐 */
+ (void)pauseMusicWithMusicName:(NSString *)musicName
{
    // 1.从内存字典中取出播放器
    AVAudioPlayer *player = _players[musicName];
    
    // 2.如果内存中有获取到播放器,暂停播放
    if (player) {
        // SINGLE: 暂停播放
        [player pause];
    }
}

/** 停止音乐 */
+ (void)stopMusicWithMusicName:(NSString *)musicName
{
    // 1.从内存字典中取出播放器
    AVAudioPlayer *player = _players[musicName];
    
    // 2.如果内存中有获取到播放器,停止播放
    if (player) {
        // SINGLE: 2.1 停止播放
        [player stop];
        // 2.2 从内存字典中移除
        [_players removeObjectForKey:musicName];
        player = nil;
    }
}


#pragma mark - 播放短音效API(SystemSoundID)

// REMARKS: 播放音效类方法
/** 播放音效 */
+ (void)playSoundWithSoundName:(NSString *)soundName
{
    // 1.先从内存缓存获取soundID
    SystemSoundID soundID = [_soundIDs[soundName] unsignedIntValue];
    
    // 2.判断内存是否存在音效资源,内存没有音效资源,则创建
    if (soundID == 0) {
        // 2.1 若不存在, 创建音效资源url
        CFURLRef url = (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
        
        // 2.2 判断url是否为空,如果为空,说明资源不存在,直接退出
        if (url == nil) return;
        
        // 2.3 生成SystemSoundID
        AudioServicesCreateSystemSoundID(url, &soundID);
        
        // 2.4 存入可变字典内存缓存
        [_soundIDs setObject:@(soundID) forKey:soundName];
    }
    
    // 3.播放音效
    AudioServicesPlaySystemSound(soundID);
}


@end
