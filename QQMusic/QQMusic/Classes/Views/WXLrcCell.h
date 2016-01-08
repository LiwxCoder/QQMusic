//
//  WXLrcCell.h
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXLrcLabel;
@interface WXLrcCell : UITableViewCell

/** 歌词的Label*/
@property (nonatomic, weak) WXLrcLabel *lrcLabel;

/** 创建cell类方法 */
+ (instancetype)lrcCellWithTableView:(UITableView *)tableView;

@end
