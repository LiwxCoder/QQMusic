//
//  NSString+TimeExtension.h
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TimeExtension)

/** 将NSTimeInterval类型的时间转换成NSString类型时间,时间格式为 02:59 */
+ (NSString *)stringWithTime:(NSTimeInterval)time;

@end
