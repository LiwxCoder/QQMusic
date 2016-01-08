//
//  WXLrcScrollView.m
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "WXLrcScrollView.h"
#import "WXLrcCell.h"
#import "WXLrcTool.h"
#import "WXLrcLineItem.h"
#import <Masonry.h>

@interface WXLrcScrollView () <UITableViewDataSource, UITableViewDelegate>
/** 显示歌词的tableView */
@property (nonatomic, weak) UITableView *tableView;

/** 歌词模型数组 数据源 */
@property (nonatomic, strong) NSArray *lrcList;

@end

@implementation WXLrcScrollView

#pragma mark - 初始化设置

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // 1.初始化设置
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame] ) {
        // 1.初始化设置
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    // SINGLE: 开启分页功能
    self.pagingEnabled = YES;
    
    // 设置tableView
    [self setupTableView];
}

/** 初始化创建tableView */
- (void)setupTableView
{
    // 1.创建tableView
    UITableView *tableView = [[UITableView alloc] init];
    [self addSubview:tableView];
    self.tableView = tableView;
    
    // 2.设置代理和数据源
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

/** layoutSubviews中布局子控件tableView */
- (void)layoutSubviews
{
    [super layoutSubviews];
    // 1.布局tableView
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(self.mas_height);
        make.left.equalTo(self.mas_left).offset(self.bounds.size.width);
        make.right.equalTo(self.mas_right);
        make.width.equalTo(self.mas_width);
    }];
    
    // SINGLE: 2.清空tableView背景颜色,取消tableView的分割线,设置tableView的内边距
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.bounds.size.height * 0.5, 0, self.tableView.bounds.size.height * 0.5, 0);
}

/** 重写set方法来解析歌词 */
- (void)setLrcFileName:(NSString *)lrcFileName
{
    // 1.保存歌词名
    _lrcFileName = lrcFileName;
    
    // 2.解析歌词,保存到数组
    self.lrcList = [WXLrcTool lrcToolWithLrcFileName:lrcFileName];
    
    // 3.刷新tableView
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lrcList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建cell
    WXLrcCell *cell = [WXLrcCell lrcCellWithTableView:tableView];

    // 2.取出数组中的模型数据
    WXLrcLineItem *item = self.lrcList[indexPath.row];
    
    cell.textLabel.text = item.name;
    return cell;
}




@end
