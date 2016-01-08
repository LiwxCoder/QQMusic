//
//  WXLrcTool.h
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXLrcTool : NSObject

/** 传入本地歌词文件名,解析歌词文件 */
+ (NSArray *)lrcToolWithLrcFileName:(NSString *)lrcFileName;

@end
