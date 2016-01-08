//
//  WXLrcTool.m
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "WXLrcTool.h"
#import "WXLrcLineItem.h"

@implementation WXLrcTool

/** 传入本地歌词文件名,解析歌词文件 */
+ (NSArray *)lrcToolWithLrcFileName:(NSString *)lrcFileName
{
    // 1.获取歌词的路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:lrcFileName ofType:nil];
    
    // 2.读取歌词文件数据
    NSString *lrcString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // SINGLE: 3.通过\n字符切割到数组
    NSArray *lrcArray = [lrcString componentsSeparatedByString:@"\n"];
    
    /** 
     歌词文件头部信息
     [ti:]
     [ar:]
     [al:]
     */
    // 4.遍历数组,将数组转模型
    NSMutableArray *lrcArrayM = [NSMutableArray array];
    for (NSString *lrcLineString in lrcArray) {
        // 1.过滤歌词文件头部无用信息,不是以[开头的也过滤掉
        if ([lrcLineString hasPrefix:@"[ti:"] || [lrcLineString hasPrefix:@"[ar:"] || [lrcLineString hasPrefix:@"[al:"] || ![lrcLineString hasPrefix:@"["]) {
            continue;
        }
        
        // 2.解析歌词数据到模型
        WXLrcLineItem *lrcItem = [WXLrcLineItem lrcLineItemWithLrcLineString:lrcLineString];
        
        // 3.添加到可变数组
        [lrcArrayM addObject:lrcItem];
    }
    
    return lrcArrayM;
}
@end
