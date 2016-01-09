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
#import "WXLrcLabel.h"

@interface WXLrcScrollView () <UITableViewDataSource, UITableViewDelegate>
/** 显示歌词的tableView */
@property (nonatomic, weak) UITableView *tableView;

/** 歌词模型数组 数据源 */
@property (nonatomic, strong) NSArray *lrcList;
/** 记录当前播放歌词的下标*/
@property (nonatomic ,assign)NSInteger currentIndex;

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

#pragma mark - 重写set方法
/** 重写set方法来解析歌词 */
- (void)setLrcFileName:(NSString *)lrcFileName
{
    // CARE: 0.切换音乐前,将当前播放的歌词清0,否则会出现当前音乐快播完后,手动切换下一首导致程序奔溃
    // 奔溃原因: 假设当前音乐歌词总60行,下一首音乐歌词共38行,当前播放到55行是调到下一首,下一首最大才38行,这样会导致tableView的数据源数组访问越界
    self.currentIndex = 0;
    
    // 1.保存歌词名
    _lrcFileName = lrcFileName;
    
    // 2.解析歌词,保存到数组
    self.lrcList = [WXLrcTool lrcToolWithLrcFileName:lrcFileName];
    // CARE: 初始设置歌词的第0行
    WXLrcLineItem *firstItem = self.lrcList[0];
    self.lrcLabel.text = firstItem.name;
    
    // 3.刷新tableView
    [self.tableView reloadData];
}

/** 重写当前播放时间set方法,该方法每秒会调用60次,因为外部用CADisplayLink定时器刷新歌词进度 */
- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    // 1.保存当前播放时间
    _currentTime = currentTime;
    
    // 2.获取歌词的总数
    NSInteger count = self.lrcList.count;
    // 3.遍历歌词数组
    for (NSInteger i = 0; i < count; i++) {
        // 3.1 获取第i位置的歌词模型
        WXLrcLineItem *currentLrcItem = self.lrcList[i];
        
        // 3.2 获取第i+1位置的歌词的模型
        NSInteger nextIndex = i + 1;
        WXLrcLineItem *nextLrcItem = nil;
        if (nextIndex < count) {
            nextLrcItem = self.lrcList[nextIndex];
        }
        
        // 3.3 判断当前播放时间是否在第 i ~ i+1歌词之间  (i位置的时间 <= self.currentTime < i+1位置的时间)
        // CARE: 因该方法每秒执行60次,考虑到内部刷新列表操作和性能问题,判断如果当前行是正在播放的歌词,就无需刷新,通过self.currentIndex != i,如果不等于i,才进入刷新列表
        if ( (self.currentIndex != i) && (currentTime >= currentLrcItem.time && currentTime < nextLrcItem.time) ) {
            
            // 1.滚动当前正在播放的歌词到中心位置,实际是滚动到最顶部,因为之前有设置内边距顶部间距是ScrollView的一半
            // SINGLE: 调用哪个tableView的滚动方法
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView scrollToRowAtIndexPath:currentIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            // CARE: 刷新主界面歌词Label内容
            self.lrcLabel.text = currentLrcItem.name;
            
            // 2.刷新上一行歌词,如果没刷新,会导致上一行的歌词字体样式和当前歌词的字体样式一样
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            
            // CARE: 3.记录当前滚动的歌词,下面刷新cell有用到self.currentIndex,此处顺序不能和以下相反
            self.currentIndex = i;
            
            // 4.刷新当前行和上一行歌词
            [self.tableView reloadRowsAtIndexPaths:@[currentIndexPath, previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        // 4.获取当前这句歌词,来获得当前播放的进度,传递当前歌词进度给cell中lrcLabel
        if (self.currentIndex == i) {
            
            // SINGLE: 1.获取当前行歌词进度 当前行歌词进度 = (当前播放的时间 - 当前行歌词的开始时间) / (下一行歌词的开始时间 - 当前行歌词的开始时间)
            CGFloat progress = (currentTime - currentLrcItem.time) / (nextLrcItem.time - currentLrcItem.time);
            
            // 2.获取当前显示歌词的cell
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            WXLrcCell *lrcCell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // 3.设置歌词进度,传递给当前歌词进度给cell中lrcLabel
            lrcCell.lrcLabel.progress = progress;
            // CARE: 将当前行歌词进度赋值给主界面传过来的歌词Label;
            self.lrcLabel.progress = progress;
        }
    }
}

/** 返回tableView的总行数 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lrcList.count;
}

/** 返回cell */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建cell
    WXLrcCell *cell = [WXLrcCell lrcCellWithTableView:tableView];

    // 2.取出数组中的模型数据
    WXLrcLineItem *item = self.lrcList[indexPath.row];
    
    // 3.设置cell歌词数据
    cell.lrcLabel.text = item.name;
    
    // 4.设置当前歌词文字样式
    if (indexPath.row == self.currentIndex) {
        // 当前播放的歌词
        cell.lrcLabel.font = [UIFont boldSystemFontOfSize:18];
    }else {
        // 非当前播放的歌词
        cell.lrcLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.lrcLabel.progress = 0;
    }
    
    return cell;
}




@end
