//
//  AppDelegate.m
//  QQMusic
//
//  Created by 李伟雄 on 16/1/7.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // REMARKS: 项目配置后台可播放音视频
    // SINGLE: 配置后台可播放音视频 工程文件->Capabilities -> Background modes ->Audio
    // CARE: 模拟器上运行时,音乐可后台运行,但是真机运行默认是不能后台播放音视频的,必须在项目中配置以上操作(后台可播放音视频),需创建会话,设置会话类别为后台播放,并激活会话.
    
    // 为确保程序运行时会执行到以下设置音视频会话(后台播放会话)代码,所以放在didFinishLaunchingWithOptions方法中执行
    // 1.创建会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // 2.设置类别为后台播放 AVAudioSessionCategoryPlayback: 类别为后台播放,该常量字符串在AVAudioSession.h中
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 3.激活会话
    [session setActive:YES error:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
