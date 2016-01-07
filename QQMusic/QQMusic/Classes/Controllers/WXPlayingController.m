//
//  WXPlayingController.m
//  QQMusic
//
//  Created by 李伟雄 on 16/1/7.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "WXPlayingController.h"
#import "WXMusicItem.h"
#import "WXMusicTool.h"
#import "WXAudioTool.h"
#import "NSString+TimeExtension.h"
#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>

@interface WXPlayingController ()

#pragma mark - 子控件
/** 背景图片 */
@property (weak, nonatomic) IBOutlet UIImageView *albumView;
/** 进度条 */
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
/** 歌手图片 */
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
/** 音乐名称 */
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
/** 歌手名 */
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
/** 当前播放的时间 */
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
/** 播放的总时间 */
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

#pragma mark - 成员属性
/** 当前播放器 */
@property (nonatomic ,strong)AVAudioPlayer *currentPlayer;
/** 进度条定时器 */
@property (nonatomic ,strong)NSTimer *progressTimer;

@end

@implementation WXPlayingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.背景添加毛玻璃效果
    [self setupBlur];
    
    // SINGLE: 2.设置UISlider滑块图片
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    
    // 3.播放音乐
    [self playingMusic];
}

#pragma mark - 播放音乐
- (void)playingMusic
{
    // 1.获取当前音乐
    WXMusicItem *playerMusicItem = [WXMusicTool playingMusic];
    
    
    // 2.更新子控件信息
    self.albumView.image = [UIImage imageNamed:playerMusicItem.icon];
    self.iconView.image = [UIImage imageNamed:playerMusicItem.icon];
    self.songLabel.text = playerMusicItem.name;
    self.singerLabel.text = playerMusicItem.singer;
    
    // 3.开始播放音乐
    AVAudioPlayer *currentPlayer = [WXAudioTool playMusicWithMusicName:playerMusicItem.filename];
    self.currentPlayer = currentPlayer;
    // 3.1 设置当前播放时间和音乐总时长
    self.currentLabel.text = [NSString stringWithTime:currentPlayer.currentTime];
    self.totalLabel.text = [NSString stringWithTime:currentPlayer.duration];
    
    // 4.添加旋转动画
    [self addIconViewAnimate];
    
    // 5.添加定时器(需先移除定时器在添加,避免当前定时器还在运行,又开启新定时器)
    [self removeProgressTimer];
    [self addProgressTimer];
    
    // 6.设置默认当前音乐播放时间,总时长和进度条
    [self updateProgressInfo];
}

#pragma mark - 定时器操作与动画
- (void)addIconViewAnimate
{
    // 1.创建核心动画,并设置期相关属性
    CABasicAnimation *anim = [CABasicAnimation animation];
    // 1.1 设置绕z轴旋转360°,无限循环等
    anim.keyPath = @"transform.rotation.z";
    anim.fromValue = @(0);
    anim.toValue = @(M_PI * 2);
    anim.repeatCount = CGFLOAT_MAX;
    anim.duration = 35;
    // SINGLE: 1.2 当进入后台,再进入前台时,核心动画会失效,需设置removedOnCompletion属性为NO,这样核心动画就不会失效
    // removedOnCompletion: 设置为NO表示动画完成的时候不要移除.
    anim.removedOnCompletion = NO;
    
    // 2.添加动画到self.iconView.layer
    [self.iconView.layer addAnimation:anim forKey:nil];
}

/** 创建用于进度条定时器 */
- (void)addProgressTimer
{
    // 1.创建定时器
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    
    // 2.添加到RunLoop
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

/** 移除定时器 */
- (void)removeProgressTimer
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

/** 更新进度条信息 */
- (void)updateProgressInfo {
    // 1.更新当前音乐播放时间和当前音乐总时长
    self.currentLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    self.totalLabel.text = [NSString stringWithTime:self.currentPlayer.duration];
    
    // 2.更新进度条信息
    self.progressSlider.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
}


#pragma mark - 初始化设置
/** 给背景添加毛玻璃效果 */
- (void)setupBlur
{
    // REMARKS: 添加毛玻璃效果
    // 1.创建toolBar,设置毛玻璃样式,添加到背景的view
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.barStyle = UIBarStyleBlack;
    [self.albumView addSubview:toolBar];
    
    // 2.toolBar添加约束
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.albumView);
    }];
}

// SINGLE: view即将布局子控件的时候调用,在该方法中可以拿到子控件的真实尺寸
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // SINGLE: 设置ImageView为圆形
    self.iconView.layer.cornerRadius = self.iconView.frame.size.width * 0.5;
    self.iconView.layer.masksToBounds = YES;
    // SINGLE: 设置ImageView边框颜色,宽度
    self.iconView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.iconView.layer.borderWidth = 5.0;
}

@end
