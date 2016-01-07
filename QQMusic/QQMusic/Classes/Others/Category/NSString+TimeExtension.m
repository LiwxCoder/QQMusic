//
//  NSString+TimeExtension.m
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "NSString+TimeExtension.h"

@implementation NSString (TimeExtension)

/** 将NSTimeInterval类型的时间转换成NSString类型时间,时间格式为 02:59 */
+ (NSString *)stringWithTime:(NSTimeInterval)time {
    // 获取分钟
    NSInteger min = time / 60;
    // SINGLE: round函数计算四舍五入 获取秒钟
    NSInteger sec = (NSInteger)round(time) % 60;
    
    return [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
}

@end
