//
//  WXLrcScrollView.m
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import "WXLrcScrollView.h"
#import "WXLrcCell.h"
#import <Masonry.h>

@interface WXLrcScrollView () <UITableViewDataSource, UITableViewDelegate>
/** 显示歌词的tableView */
@property (nonatomic, weak) UITableView *tableView;

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXLrcCell *cell = [WXLrcCell lrcCellWithTableView:tableView];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%02ld. 测试", indexPath.row];
    return cell;
}


@end
