//
//  WXLrcLineItem.m
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "WXLrcLineItem.h"

@implementation WXLrcLineItem


/** 创建WXLrcLineItem的对象方法 */
- (instancetype)initWithLrcLineString:(NSString *)lrcLineString
{
    if (self = [super init]) {
        // 1.解析歌词
        [self lrcStringToItem:lrcLineString];
    }
    return self;
}

/** 创建WXLrcLineItem的类方法 */
+ (instancetype)lrcLineItemWithLrcLineString:(NSString *)lrcLineString
{
    return [[self alloc] initWithLrcLineString:lrcLineString];
}

/** 解析歌词 */
- (void)lrcStringToItem:(NSString *)lrcLineString
{
    // 歌词数据: [00:33.20]只是因为在人群中多看了你一眼
    // 1.以"]"切割歌词与时间
    NSArray *lrcArray = [lrcLineString componentsSeparatedByString:@"]"];
    
    // 2.解析出歌词内容 只是因为在人群中多看了你一眼
    self.name = lrcArray[1];
    
    // 3.解析时间 [00:31.25
    NSString *timeString = lrcArray[0];
    self.time = [self timeWithTimeString:[timeString substringFromIndex:1]];
}

/** 解析时间 时间数据: 00:31.25 */
- (NSTimeInterval)timeWithTimeString:(NSString *)timeString {
    
    NSLog(@"time: %@",timeString);
    NSInteger min = [[timeString componentsSeparatedByString:@":"][0] integerValue];
    NSInteger sec = [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue];
    NSInteger mSec = [[timeString componentsSeparatedByString:@"."][1] integerValue];
    
    NSLog(@"%02ld:%02ld:%02ld", min, sec, mSec);
    return min * 60 + sec + mSec * 0.01;
}




@end
