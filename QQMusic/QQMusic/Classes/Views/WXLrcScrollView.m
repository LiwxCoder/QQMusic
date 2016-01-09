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
#import "WXLrcLabel.h"
#import "WXMusicTool.h"
#import "WXMusicItem.h"

#import <Masonry.h>
#import <MediaPlayer/MediaPlayer.h>

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
            
            // 5.设置重新绘制锁屏封面和歌词,锁屏界面
            [self setupLockImage];
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

#pragma mark - 设置锁屏界面和锁屏歌词

/** 绘制锁屏封面和歌词 */
- (void)setupLockImage
{
    // 1.获取当前音乐的模型
    WXMusicItem *currentMusicItem = [WXMusicTool playingMusic];
    
    // 2.从当前音乐模型取出封面图片
    UIImage *currentImage = [UIImage imageNamed:currentMusicItem.icon];
    
    // 3.获取当前,上一行,下一行歌词
    // 3.1 获取当前行歌词
    WXLrcLineItem *currentLrcLine = self.lrcList[self.currentIndex];
    
    // 3.2 获取上一行歌词
    NSInteger previousIndex = self.currentIndex - 1;
    WXLrcLineItem *previousLrcLine = nil;
    if (previousIndex >= 0) {
        previousLrcLine = self.lrcList[previousIndex];
    }
    
    // 3.3 获取下一行歌词
    NSInteger nextIndex = self.currentIndex + 1;
    WXLrcLineItem *nextLrcLine = nil;
    if (nextIndex < self.lrcList.count) {
        nextLrcLine = self.lrcList[nextIndex];
    }
    
    // 4.绘制图片
    // 4.1 开启和图片尺寸一样的上下文
    UIGraphicsBeginImageContext(currentImage.size);
    
    // 4.2 绘制图片
    [currentImage drawInRect:CGRectMake(0, 0, currentImage.size.width, currentImage.size.height)];
    
    // 4.3 将歌词文字绘制上去
    // 设置文字高度
    CGFloat titleH = 25;
    
    // 4.3.1 绘制上一句歌词和下一句歌词
    // SINGLE: 设置绘制文字居中
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *otherAttr = @{
                                NSFontAttributeName : [UIFont systemFontOfSize:12],
                                NSForegroundColorAttributeName : [UIColor yellowColor],
                                NSParagraphStyleAttributeName : paragraphStyle
                                };
    // 绘制上一句和下一句歌词(绘制到图片底部)
    [previousLrcLine.name drawInRect:CGRectMake(0, currentImage.size.height - titleH * 3, currentImage.size.width, titleH) withAttributes:otherAttr];
    [nextLrcLine.name drawInRect:CGRectMake(0, currentImage.size.height - titleH, currentImage.size.width, titleH) withAttributes:otherAttr];
    
    // 4.3.2 绘制当前行歌词文字
    NSDictionary *currentAttr = @{
                                  NSFontAttributeName : [UIFont systemFontOfSize:18],
                                  NSForegroundColorAttributeName : [UIColor greenColor],
                                  NSParagraphStyleAttributeName : paragraphStyle
                                  };
    [currentLrcLine.name drawInRect:CGRectMake(0, currentImage.size.height - titleH * 2, currentImage.size.width, titleH) withAttributes:currentAttr];
    
    // 4.4 生成绘制好的图片
    UIImage *lockImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 4.5 关闭图形上下文
    UIGraphicsEndImageContext();
    
    // 5.将生成的图片添加到锁屏的封面图片上
    [self setupLockScreenInfoWithLockImage:lockImage];
}

// REMARKS: 设置锁屏界面
/** 设置锁屏界面 */
- (void)setupLockScreenInfoWithLockImage:(UIImage *)lockImage
{
    /*
     // 媒体常量
     MPMediaItemPropertyAlbumTitle           // 媒体音乐的标题（或名称）
     MPMediaItemPropertyAlbumTrackCount
     MPMediaItemPropertyAlbumTrackNumber
     MPMediaItemPropertyArtist               // 作者
     MPMediaItemPropertyArtwork              // 封面
     MPMediaItemPropertyComposer             // 音乐剧作曲家的媒体项目
     MPMediaItemPropertyDiscCount            // 光盘在包含媒体项目的专辑的数目
     MPMediaItemPropertyDiscNumber
     MPMediaItemPropertyGenre
     MPMediaItemPropertyPersistentID
     MPMediaItemPropertyPlaybackDuration     // 媒体项目的播放持续时间(当前播放时间)
     MPMediaItemPropertyTitle                // 显示在作者和标题上面
     */
    
    // REMARKS: 设置锁屏界面,MPNowPlayingInfoCenter锁屏中心类在MediaPlayer框架中,所以需导入MediaPlayer/MediaPlayer.h头文件
    // 1.获取当前正在播放的音乐
    WXMusicItem *playingMusicItem = [WXMusicTool playingMusic];
    
    // 2.获取锁屏中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // 3.设置锁屏中心要展示的信息,通过设置锁屏中心nowPlayingInfo属性设置,该属性是字典
    // 创建要可变字典,用来存放要显示在锁屏中心的信息
    NSMutableDictionary *playingInfoDict = [NSMutableDictionary dictionary];
    // 3.1 设置展示的音乐名称
    [playingInfoDict setObject:playingMusicItem.name forKey:MPMediaItemPropertyAlbumTitle];
    
    // 3.2 设置展示的歌手名
    [playingInfoDict setObject:playingMusicItem.singer forKey:MPMediaItemPropertyArtist];
    
    // 3.3 设置展示封面
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:lockImage];
    [playingInfoDict setObject:artWork forKey:MPMediaItemPropertyArtwork];
    
    // 3.4 设置音乐播放的总时间
    [playingInfoDict setObject:@(self.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    
    // 3.5 设置音乐当前播放的时间
    [playingInfoDict setObject:@(self.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    //    [playingInfoDict setObject:@"sdfsfsdf" forKey:MPMediaItemPropertyTitle];
    
    // 3.6 将设置的字典信息赋给nowPlayingInfo属性
    playingInfoCenter.nowPlayingInfo = playingInfoDict;
    
    // SINGLE: 4.让应用程序开启远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}




@end
