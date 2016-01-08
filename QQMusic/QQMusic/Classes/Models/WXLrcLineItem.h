//
//  WXLrcLineItem.h
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXLrcLineItem : NSObject

/** 歌词 */
@property (nonatomic ,copy)NSString *name;
/** 歌词的时间 */
@property (nonatomic ,assign)NSTimeInterval time;

/** 创建WXLrcLineItem的对象方法 */
- (instancetype)initWithLrcLineString:(NSString *)lrcLineString;
/** 创建WXLrcLineItem的类方法 */
+ (instancetype)lrcLineItemWithLrcLineString:(NSString *)lrcLineString;

@end
