//
//  WXLrcCell.m
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "WXLrcCell.h"

@implementation WXLrcCell

/** 创建cell类方法 */
+ (instancetype)lrcCellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"lrcCell";
    
    // 1.先从缓冲池取cell
    WXLrcCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 2.判断cell是否存在缓存
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    return cell;
}

/** 重写方法,初始化设置cell */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // 1.初始化cell属性
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        // SINGLE: 取消选中样式
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
