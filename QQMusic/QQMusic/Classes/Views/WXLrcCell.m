//
//  WXLrcCell.m
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "WXLrcCell.h"
#import "WXLrcLabel.h"
#import <Masonry.h>

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
        
        // SINGLE: 1.设置取消选中样式,设置cell背景色为透明颜色
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        // 2.创建歌词Label
        WXLrcLabel *lrcLabel = [[WXLrcLabel alloc] init];
        self.lrcLabel = lrcLabel;
        [self.contentView addSubview:lrcLabel];
        
        // 3.设置cell约束,让歌词Label位置居中
        [lrcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        
        // 4.初始化cell属性
        lrcLabel.textColor = [UIColor whiteColor];
        lrcLabel.textAlignment = NSTextAlignmentCenter;
        lrcLabel.font = [UIFont systemFontOfSize:14];
    }
    return self;
}

@end
