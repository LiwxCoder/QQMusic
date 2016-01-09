//
//  WXLrcLabel.m
//  QQMusic
//
//  Created by 李伟雄 on 16/1/9.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "WXLrcLabel.h"

@implementation WXLrcLabel

/** 重写progress当前行歌词播放的进度,用于刷新重绘Label */
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    // 刷新重绘Label
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // 1.设置填充的颜色
    [[UIColor greenColor] set];
    
    // 2.设置要填充的尺寸,根据传递过来的歌词播放进度
    CGRect fullRect = CGRectMake(0, 0, self.bounds.size.width * self.progress, self.bounds.size.height);
    
    // 3.开始绘制
    // SINGLE: UIRectFill会填充Label颜色,不是填充文字颜色
//    UIRectFill(fullRect);
    // SINGLE: UIRectFillUsingBlendMode(fullRect, kCGBlendModeSourceIn)填充文字,kCGBlendModeSourceOut:表示填充文字以外的区域
    UIRectFillUsingBlendMode(fullRect, kCGBlendModeSourceIn);
}



@end
