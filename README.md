# 32.音视频播放-01 QQ音乐界面搭建 (自己整理)

@(iOS Study)[音视频播放]

- 作者: <font size="3" color="Peru">Liwx</font>
- 邮箱: <font size="3" color="Peru">1032282633@qq.com</font>

---

[TOC]

---

# QQ音乐界面搭建
- QQ音乐运行效果(模拟器不能演示锁屏界面的功能,所以展示效果图没有锁屏界面功能展示)
![Alt text](./QQMusic.gif)

---
## 1.storyboard布局QQ音乐界面
### QQ音乐主界面整体框图
- 界面效果图
![Alt text](./Snip20160110_4.png)

- UISlider添加手势
![Alt text](./Snip20160108_1.png)
- UILabel作为其他控件布局的参考控件注意点
- 如果UILabel的(顶部Top或底部Bottom)作为其他控件布局的参考对象的时候,需对设置UILabel的高度约束.  高度约束如下图所示
![Alt text](./Snip20160110_5.png) 

### 界面控件设置
- 设置毛玻璃效果的几种方式
- 美工做一张毛玻璃效果的图片  
- 使用UIToolbar
- 使用第三方框架
- 使用coreImage
- 使用UIVisualEffectView (Blur)
![Alt text](./1452410858326.png)
- 设置背景**毛玻璃**效果
- 本示例使用UIToolbar做毛玻璃效果
- 示例代码
```
/** 给背景添加毛玻璃效果 */
- (void)setupBlur
{
// REMARKS: 添加毛玻璃效果
// 1.创建toolBar,设置毛玻璃样式,添加到背景的view
UIToolbar *toolBar = [[UIToolbar alloc] init];
toolBar.barStyle = UIBarStyleBlack;
[self.albumView addSubview:toolBar];

// 2.toolBar添加约束
[toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
make.edges.equalTo(self.albumView);
}];
}
```

- 设置歌手图标圆角效果
- 在**view即将布局子控件**的时候调用`viewWillLayoutSubviews方法`,该方法中可以获取`子控件的真实尺寸`
```objectivec
// SINGLE: view即将布局子控件的时候调用,在该方法中可以拿到子控件的真实尺寸
- (void)viewWillLayoutSubviews
{
[super viewWillLayoutSubviews];

// SINGLE: 设置ImageView为圆形
self.iconView.layer.cornerRadius = self.iconView.frame.size.width * 0.5;
self.iconView.layer.masksToBounds = YES;
// SINGLE: 设置ImageView边框颜色,宽度
self.iconView.layer.borderColor = [UIColor lightGrayColor].CGColor;
self.iconView.layer.borderWidth = 5.0;
}
```

- 设置UISlider滚动条`滑块图片`
```objectivec
// SINGLE: 2.设置UISlider滑块图片
[self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
```

---
## 2.实现音乐的播放
### 封装WXAudioTool播放音效和播放音乐工具类
#### 播放音效/音乐工具类实现步骤
- 1.创建一个可变字典用于存放`音乐播放器AVAudioPlayer`,创建一个可变字典用于存放`播放音效SystemSoundID`,作为音乐播放器和音效播放的内存缓存.
- 音乐播放器和音效播放器缓存只需创建一次,所以将其放在initialize方法中进行初始化操作.示例代码如下
```objectivec
#pragma mark - 初始化设置
/** 创建内存缓存 */
+ (void)initialize {
// 创建可变字典,用于存放播放音效SystemSoundID
_soundIDs = [NSMutableDictionary dictionary];

// 创建可变字典,用于存放音乐播放器AVAudioPlayer
_players = [NSMutableDictionary dictionary];
}
```

- 2.WXAudioTool工具类实现播放等API接口方法
- 实现播放音乐,暂停音乐,停止音乐和播放音效API接口方法
**播放音乐:** + (AVAudioPlayer *)playMusicWithMusicName:(NSString *)musicName;
**暂停音乐:** + (void)pauseMusicWithMusicName:(NSString *)musicName;
**停止音乐:** + (void)stopMusicWithMusicName:(NSString *)musicName;
**播放音效:** + (void)playSoundWithSoundName:(NSString *)soundName;

- 3.WXAudioTool工具类实现代码
```objectivec
#import "WXAudioTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation WXAudioTool

// SINGLE: 创建一个可变字典缓存音乐,字典只需创建一次,可以在initialize类方法中创建
static NSMutableDictionary *_soundIDs;
// SINGLE: 创建音乐内存缓存,在initialize类方法中创建
static NSMutableDictionary *_players;

#pragma mark - 初始化设置
/** 创建内存缓存 */
+ (void)initialize {
// 创建可变字典,用于存放播放音效SystemSoundID
_soundIDs = [NSMutableDictionary dictionary];

// 创建可变字典,用于存放音乐播放器AVAudioPlayer
_players = [NSMutableDictionary dictionary];
}


#pragma mark - 播放音乐API(AVAudioPlayer)
/** 播放音乐 */
+ (AVAudioPlayer *)playMusicWithMusicName:(NSString *)musicName
{
// 1.先从内存字典中获取播放器AVAudioPlayer
AVAudioPlayer *player = _players[musicName];

// 2.判断是否从内存获取到播放器,如果没有获取到,新建播放器
if (player == nil) {
// 2.1 获取音乐文件的url
NSURL *url = [[NSBundle mainBundle] URLForResource:musicName withExtension:nil];
if (url == nil) return nil;

// 2.2 根据音频文件的url,创建播放器
player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];

// 2.3 保存到内存缓存_players
[_players setObject:player forKey:musicName];
}

// SINGLE: 3.播放音乐
[player play];

return player;
}

/** 暂停音乐 */
+ (void)pauseMusicWithMusicName:(NSString *)musicName
{
// 1.从内存字典中取出播放器
AVAudioPlayer *player = _players[musicName];

// 2.如果内存中有获取到播放器,暂停播放
if (player) {
// SINGLE: 暂停播放
[player pause];
}
}

/** 停止音乐 */
+ (void)stopMusicWithMusicName:(NSString *)musicName
{
// 1.从内存字典中取出播放器
AVAudioPlayer *player = _players[musicName];

// 2.如果内存中有获取到播放器,停止播放
if (player) {
// SINGLE: 2.1 停止播放
[player stop];
// 2.2 从内存字典中移除
[_players removeObjectForKey:musicName];
player = nil;
}
}


#pragma mark - 播放短音效API(SystemSoundID)

// REMARKS: 播放音效类方法
/** 播放音效 */
+ (void)playSoundWithSoundName:(NSString *)soundName
{
// 1.先从内存缓存获取soundID
SystemSoundID soundID = [_soundIDs[soundName] unsignedIntValue];

// 2.判断内存是否存在音效资源,内存没有音效资源,则创建
if (soundID == 0) {
// 2.1 若不存在, 创建音效资源url
CFURLRef url = (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:soundName withExtension:nil];

// 2.2 判断url是否为空,如果为空,说明资源不存在,直接退出
if (url == nil) return;

// 2.3 生成SystemSoundID
AudioServicesCreateSystemSoundID(url, &soundID);

// 2.4 存入可变字典内存缓存
[_soundIDs setObject:@(soundID) forKey:soundName];
}

// 3.播放音效
AudioServicesPlaySystemSound(soundID);
}

@end
```

### 封装WXMusicTool获取音乐列表工具类
- 1.创建WXMusicItem音乐模型
```objectivec
@interface WXMusicItem : NSObject
/** 音乐名 */
@property (nonatomic ,copy)NSString *name;
/** 音乐文件名 */
@property (nonatomic ,copy)NSString *filename;
/** 歌词文件名 */
@property (nonatomic ,copy)NSString *lrcname;
/** 歌手名 */
@property (nonatomic ,copy)NSString *singer;
/** 歌手小图标 */
@property (nonatomic ,copy)NSString *singerIcon;
/** 歌手大图标 */
@property (nonatomic ,copy)NSString *icon;
@end
```
- 2.WXMusicTool工具类实现API接口方法
- 实现播放音乐,暂停音乐,停止音乐和播放音效API接口方法
**获取所有的音乐:** + (NSArray *)musics;
**获取正在播放的音乐:** + (WXMusicItem *)playingMusic;
**设置播放的音乐:** + (void)setupMusic:(WXMusicItem *)music;
**获取上一首音乐:** + (WXMusicItem *)previous;
**获取下一首音乐:** + (WXMusicItem *)next;

- 3.WXMusicTool工具类实现代码
```objectivec
#import "WXMusicTool.h"
#import "WXMusicItem.h"
#import <MJExtension.h>

@implementation WXMusicTool

#pragma mark - 静态变量
/** 所有音乐 */
static NSArray *_musicItems;
/** 当前播放的音乐 */
static WXMusicItem *_playingMusicItem;

/** 获取所有音乐模型,设置当前默认音乐 */
+ (void)initialize
{
// 从plist文件中获取所有音乐模型
_musicItems = [WXMusicItem mj_objectArrayWithFilename:@"Musics.plist"];
// 设置当前默认音乐
_playingMusicItem = _musicItems[4];
}

#pragma mark - 播放音乐操作
/** 获取所有的音乐 */
+ (NSArray *)musics
{
return _musicItems;
}

/** 获取正在播放的音乐(默认) */
+ (WXMusicItem *)playingMusic
{
return _playingMusicItem;
}

/** 设置播放的音乐 */
+ (void)setupMusic:(WXMusicItem *)music
{
_playingMusicItem = music;
}

/** 获取上一首音乐 */
+ (WXMusicItem *)previous
{
// 1.获取当前音乐的下标值
NSInteger currentIndex = [_musicItems indexOfObject:_playingMusicItem];

// 2.获取上一首音乐的下标值,判断是否越界
NSInteger previousIndex = currentIndex - 1;
if (previousIndex < 0) {
previousIndex = _musicItems.count - 1;
}

// 3.获取上一首的音乐
WXMusicItem *previousMusicItem = _musicItems[previousIndex];

// 4.返回上一首音乐
return previousMusicItem;
}

/** 获取下一首音乐 */
+ (WXMusicItem *)next
{
// 1.获取当前音乐的下标值
NSInteger currentIndex = [_musicItems indexOfObject:_playingMusicItem];

// 2.获取下一首音乐的下标值,判断是否越界
NSInteger nextIndex = currentIndex + 1;
if (nextIndex >= _musicItems.count) {
nextIndex = 0;
}

// 3.获取下一首的音乐
WXMusicItem *nextMusicItem = _musicItems[nextIndex];

// 4.返回下一首音乐
return nextMusicItem;
}
@end
```

### 在主控制器实现播放音乐
- 播放音乐实现
```objectivec
#pragma mark - 播放音乐
- (void)playingMusic
{
// 1.获取当前音乐
WXMusicItem *playerMusicItem = [WXMusicTool playingMusic];

// 2.更新子控件信息
self.albumView.image = [UIImage imageNamed:playerMusicItem.icon];
self.iconView.image = [UIImage imageNamed:playerMusicItem.icon];
self.songLabel.text = playerMusicItem.name;
self.singerLabel.text = playerMusicItem.singer;

// 3.开始播放音乐
AVAudioPlayer *currentPlayer = [WXAudioTool playMusicWithMusicName:playerMusicItem.filename];
// 3.0 设置代理,用来监听音乐播放完毕,实现自动切换到下一首的功能
currentPlayer.delegate = self;
self.currentPlayer = currentPlayer;
// 3.1 设置当前播放时间和音乐总时长
self.currentLabel.text = [NSString stringWithTime:currentPlayer.currentTime];
self.totalLabel.text = [NSString stringWithTime:currentPlayer.duration];
// 3.2 更新当前播放按钮的状态
self.playOrPauseBtn.selected = self.currentPlayer.isPlaying;
// 3.3 设置当前播放的音乐的歌词
self.lrcScrollView.lrcFileName = playerMusicItem.lrcname;
// 3.4 将当前播放的音乐的总时长传给lrcScrollView,用于做锁屏界面的总时长
self.lrcScrollView.duration = currentPlayer.duration;

// 4.添加旋转动画
[self addIconViewAnimate];

// 5.添加定时器(需先移除定时器在添加,避免当前定时器还在运行,又开启新定时器)
[self removeProgressTimer];
[self addProgressTimer];

// 6.添加更新歌词定时器
[self removeLrcTimer];
[self addLrcTimer];

// 7.设置默认当前音乐播放时间,总时长和进度条
[self updateProgressInfo];
}
```

---
## 3.添加播放进度定时器,更新播放进度
> 1.添加定时器步骤,需**先移除当前定时器,再添加定时器**.
> 2.将定时器添加到NSRunLoop,并设置**NSRunLoopCommonModes**模式.
> 3.歌手图标旋转动画实现,使用基础核心动画CABasicAnimation,设置绕z轴旋转360°无限循环等动画属性配置.
### 实现更新播放进度功能和歌手图标旋转功能
- 播放进度定时器创建/移除方法
- **创建播放进度定时器:** - (void)addProgressTimer;
- **移除播放进度定时器:** - (void)removeProgressTimer;

### 实时更新播放进度信息
- 更新进度进度实现
```objectivec
- (void)updateProgressInfo {
// 1.更新当前音乐播放时间和当前音乐总时长
self.currentLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
self.totalLabel.text = [NSString stringWithTime:self.currentPlayer.duration];

// 2.更新进度条信息
self.progressSlider.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
}
```

### 歌手图标旋转动画
- 歌手图标旋转动画实现
```objectivec
- (void)addIconViewAnimate
{
// 1.创建核心动画,并设置期相关属性
CABasicAnimation *anim = [CABasicAnimation animation];
// 1.1 设置绕z轴旋转360°,无限循环等
anim.keyPath = @"transform.rotation.z";
anim.fromValue = @(0);
anim.toValue = @(M_PI * 2);
anim.repeatCount = CGFLOAT_MAX;
anim.duration = 35;
// SINGLE: 1.2 当进入后台,再进入前台时,核心动画会失效,需设置removedOnCompletion属性为NO,这样核心动画就不会失效
// removedOnCompletion: 设置为NO表示动画完成的时候不要移除.
anim.removedOnCompletion = NO;

// 2.添加动画到self.iconView.layer
[self.iconView.layer addAnimation:anim forKey:nil];
}
```

---
## 4.处理滚动条
### 自定义滚动歌词的WXLrcScrollView,继承UIScrollView
- 1.在WXLrcScrollView初始化时,添加滚动歌词的tableView
- 在`initWithCoder`和`initWithFrame`方法中**开启分页功能**,初始化和`添加tableView`到WXLrcScrollView
- 设置子控件tableView的数据源和代理,实现数据源方法,为tableView提供显示的测试数据
- 在layoutSubviews中**添加tableView的约束**,并设置**tableView背景颜色,分割线,内边距**等,必须在layoutSubviews中设置,否则会tableView中的歌词播放不同步,背景为白色等问题.
```objectivec
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
```

---
## 5.播放/暂停,上一首,下一首功能实现,音乐播放完毕自动切换到下一首
> 在storyboard中设置播放按钮在Normal/Selected状态下的按钮显示的图片
### 播放/暂停,上一首,下一首功能实现
- 播放/暂停功能实现
- 切换播放按钮的状态 
- 判断是否正在播放,如果当前正在播放则暂停播放,反之则继续播放
- 暂停播放: 暂停播放,移除定时器,暂停动画(分类实现暂停和继续动画) 
- 继续播放: 继续播放,开启定时器,继续动画 
- 上一首/下一首功能实现
- 使用WXMusicTool工具类获取上一首/下一首音乐
- 实现切换音乐的方法
- 示例代码
```objectivec
/** 下一首 */
- (IBAction)nextMusic {

// 1.获取下一首音乐
WXMusicItem *nextMusicItem = [WXMusicTool next];

// 2.播放下一首音乐
[self playMusic:nextMusicItem];

}
/** 上一首 */
- (IBAction)previousMusic {
// 1.获取上一首音乐
WXMusicItem *previousMusicItem = [WXMusicTool previous];

// 2.播放上一首音乐
[self playMusic:previousMusicItem];
}
/** 切换播放的音乐 */
- (void)playMusic:(WXMusicItem *)music {
// 1.获取当前音乐,并暂停播放
WXMusicItem *curMusicItem = [WXMusicTool playingMusic];
[WXAudioTool pauseMusicWithMusicName:curMusicItem.filename];

// 2.设置当前播放音乐music
[WXMusicTool setupMusic:music];

// 3.开始播放音乐
[self playingMusic];
}
```

### 音乐播放完毕自动切换到下一首
- 主控制器的当前播放器遵守`AVAudioPlayerDelegate`代理协议
- 在播放器创建完成时设置代理,用来监听音乐播放完毕,实现自动切换到下一首的功能
self.currentPlayer.delegate = self;
- 实现代理方法`audioPlayerDidFinishPlaying:successfully`,**当前音乐正常播放完成后调用**.
```objectivec
#pragma mark - <AVAudioPlayerDelegate>代理协议
// SINGLE: 当前音乐播放完成后调用,在<AVAudioPlayerDelegate>代理协议中
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
// flag == YES 表示音乐播放正常停止,播放完毕自动切换到下一首
if (flag) {
// 音乐播放完毕自动切换下一首
[self nextMusic];
}
}
```

---
## 6.设置进度条UISlider的处理
### 监听进度条的事件
- 监听进度条`TouchDown事件`,当UISlider监听到TouchDown事件时,移除进度条定时器
- 监听进度条`TouchUpInside事件`,当UISlider监听到TouchUpInside事件时,更新当前播放进度,并重新开启定时器
- 监听到进度条`ValueChange事`件,拖动UISlider时,使用**UISlider的value属性和当前音乐总时长计算当前播放进度**,并更新当前播放时间Label的文字信息.
```objectivec
self.currentLabel.text = [NSString stringWithTime:self.progressSlider.value * self.currentPlayer.duration];
```
### 进度条添加Tap敲击手势
- 在Main.storyboard给UISlider进度条添加点击Tap手势
![Alt text](./Snip20160108_1.png)
- 监听敲击手势代码实现
```objectivec
/** 监听进度条点击Tap手势 */
- (IBAction)sliderTap:(UITapGestureRecognizer *)sender {
// 1.获取当前点的位置
CGPoint curPoint = [sender locationInView:sender.view];

// 2.获取当前点与总进度的比例
CGFloat ratio = curPoint.x / self.progressSlider.bounds.size.width;

// 3.更新当前播放器的播放时间
self.currentPlayer.currentTime = ratio * self.currentPlayer.duration;

// 4.更新当前播放时间Label,总时长Label的信息和进度条信息,因为updateProgressInfo方法使用self.currentPlayer.currentTime值,所以必须在第3步执行完才能执行updateProgressInfo方法,如果顺序反之,则不行
[self updateProgressInfo];
}

/** 实时更新播放进度信息 */
- (void)updateProgressInfo {
// 1.更新当前音乐播放时间和当前音乐总时长
self.currentLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
self.totalLabel.text = [NSString stringWithTime:self.currentPlayer.duration];

// 2.更新进度条信息
self.progressSlider.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
}
```

---
## 7.歌词的解析

### 歌词模型类功能的实现
- 歌词模型类的属性: `当前行歌词的播放时间`,`歌词内容`
- 实现当前行歌词的解析,当前行歌词数据格式: [00:33.20]只是因为在人群中多看了你一眼
```objectivec
#import "WXLrcLineItem.h"

@implementation WXLrcLineItem

/** 创建WXLrcLineItem的对象方法 */
- (instancetype)initWithLrcLineString:(NSString *)lrcLineString
{
if (self = [super init]) {
// 1.解析歌词
[self lrcStringToItem:lrcLineString];
}
return self;
}

/** 创建WXLrcLineItem的类方法 */
+ (instancetype)lrcLineItemWithLrcLineString:(NSString *)lrcLineString
{
return [[self alloc] initWithLrcLineString:lrcLineString];
}

/** 解析歌词 */
- (void)lrcStringToItem:(NSString *)lrcLineString
{
// 歌词数据: [00:33.20]只是因为在人群中多看了你一眼
// 1.以"]"切割歌词与时间
NSArray *lrcArray = [lrcLineString componentsSeparatedByString:@"]"];

// 2.解析出歌词内容 只是因为在人群中多看了你一眼
self.name = lrcArray[1];

// 3.解析时间 [00:31.25
NSString *timeString = lrcArray[0];
self.time = [self timeWithTimeString:[timeString substringFromIndex:1]];
}

/** 解析时间 时间数据: 00:31.25 */
- (NSTimeInterval)timeWithTimeString:(NSString *)timeString {

NSInteger min = [[timeString componentsSeparatedByString:@":"][0] integerValue];
NSInteger sec = [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue];
NSInteger mSec = [[timeString componentsSeparatedByString:@"."][1] integerValue];

return min * 60 + sec + mSec * 0.01;
}
@end
```

### 创建歌词文件处理WXLrcTool工具类
- 实现将歌词文件转换成歌词模型数组
```objectivec
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
```

---
## 8.实现歌词ScrollView歌词的滚动功能
### 主界面控制器创建更新歌词的定时器CADisplayLink定时器
- 提供创建/移除用于更新歌词的定时器的方法
- 在定时器定时执行的方法中将当前的播放时间传递给lrcScrollView的currentTime属性,让lrcScrollView实现歌词的进度更新
self.lrcScrollView.currentTime = self.currentPlayer.currentTime;

### 自定义显示歌词的WXLrcLabel
- 对外提供当前行歌词的进度progress属性,让外部为其设置当前歌词的进度
- 重写- (void)drawRect:(CGRect)rect方法绘制WXLrcLabel
- `UIRectFill`会**填充Label颜色,不是填充文字颜色**.  UIRectFill(fullRect);
- `UIRectFillUsingBlendMode`填充文字函数,kCGBlendModeSourceOut:表示填充文字以外的区域

```objectivec
- (void)drawRect:(CGRect)rect
{
[super drawRect:rect];

// 1.设置填充的颜色
[[UIColor greenColor] set];

// 2.设置要填充的尺寸,根据传递过来的歌词播放进度
CGRect fullRect = CGRectMake(0, 0, self.bounds.size.width * self.progress, self.bounds.size.height);

// 3.开始绘制
// SINGLE: UIRectFill会填充Label颜色,不是填充文字颜色
//    UIRectFill(fullRect);
// SINGLE: UIRectFillUsingBlendMode(fullRect, kCGBlendModeSourceIn)填充文字,kCGBlendModeSourceOut:表示填充文字以外的区域
UIRectFillUsingBlendMode(fullRect, kCGBlendModeSourceIn);
}
```
- 重写progress当前行歌词播放的进度,用于刷新重绘Label,在方法内部调用setNeedsDisplay重绘Label

### 实现歌词的滚动,当前行歌词进度颜色填充效果
- 重写lrcFileName属性set方法来设置tableView中的歌词
- `歌词bug注意`: 必须将指向当前播放的歌词行数清0,否则在音乐快播放完成时手动切换下一首会导致程序崩溃.奔溃原因: 假设当前音乐歌词总60行,下一首音乐歌词共38行,当前播放到55行是调到下一首,下一首最大才38行,这样会导致tableView的数据源数组访问越界.
```objectivec
- (void)setLrcFileName:(NSString *)lrcFileName
{
// CARE: 0.切换音乐前,将当前播放的歌词清0,否则会出现当前音乐快播完后,手动切换下一首导致程序奔溃
// 奔溃原因: 假设当前音乐歌词总60行,下一首音乐歌词共38行,当前播放到55行是调到下一首,下一首最大才38行,这样会导致tableView的数据源数组访问越界
// 0.指向当前播放的歌词行数清0
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
```

- 实时刷新当前歌词进度
- 滚动tableView的方法, scrollPosition: UITableViewScrollPositionTop表示tableView滚动到顶部
**- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;**

- 计算当前行歌词的进度
获取当前行歌词进度 当前行歌词进度 = (当前播放的时间 - 当前行歌词的开始时间) / (下一行歌词的开始时间 - 当前行歌词的开始时间)
- 因该方法每秒执行60次,考虑到内部刷新列表操作和性能问题,判断如果当前行是正在播放的歌词,就无需刷新,通过self.currentIndex != i,如果不等于i,才进入刷新列表
- 设置当前行歌词后,要刷新当前行和上一行歌词的cell



```objectivec
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
```

---
## 10.设置主界面的歌词
### 在主界面中设置主界面歌词
- 在初始化歌词的ScrollView的setupLrcScrollView方法中初始设置lrcLabel主界面歌词Label
```objectivec
self.lrcLabel.text = nil;
// 3.将主界面的歌词的Label传给lrcScrollView的一个属性 - >lrcLabel,让lrcScrollView为其文字属性,歌词进度赋值
self.lrcScrollView.lrcLabel = self.lrcLabel;
```

- 在scrollViewDidScroll方法中,设置self.lrcLabel的透明度,实现拖动时,主界面歌词渐变效果
```objectivec
/** 监听歌词的lrcScrollView的拖动 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
// 1.获取当前点
CGPoint curPoint = scrollView.contentOffset;

// 2.通过偏移量获取滑动的比例
CGFloat ratio = (1 - curPoint.x / self.lrcScrollView.bounds.size.width);

// 3.改变主界面中间歌手图片iconView和主界面单行歌词的透明度
self.iconView.alpha = ratio;
self.lrcLabel.alpha = ratio;
}
```

### 由lrcScrollView内部为主界面歌词内容和进度进行更新
- 在WXLrcScrollView的setCurrentTime方法中设置主界面歌词的内容和进度
- 刷新主界面歌词Label内容
self.lrcLabel.text = currentLrcItem.name;
- 将当前行歌词进度赋值给主界面传过来的歌词Label;
self.lrcLabel.progress = progress;

---
## 11.实现锁屏界面信息展示和操作
### 锁屏界面项目配置
- 设置项目可播放音视频步骤
- 配置后台可播放音视频 **工程文件->Capabilities -> Background modes ->Audio**
![Alt text](./Snip20160109_1.png)
- 创建后台播放音视频的会话,并激活会话
```objectivec
// 1.创建会话
AVAudioSession *session = [AVAudioSession sharedInstance];

// 2.设置类别为后台播放 AVAudioSessionCategoryPlayback: 类别为后台播放,该常量字符串在AVAudioSession.h中
[session setCategory:AVAudioSessionCategoryPlayback error:nil];

// 3.激活会话
[session setActive:YES error:nil];
```

- 在AppDelegate.m的didFinishLaunchingWithOptions方法中**创建后台播放音视频的会话,并激活会话**
```objectivec
// REMARKS: 项目配置后台可播放音视频
// SINGLE: 配置后台可播放音视频 工程文件->Capabilities -> Background modes ->Audio
// CARE: 模拟器上运行时,音乐可后台运行,但是真机运行默认是不能后台播放音视频的,必须在项目中配置以上操作(后台可播放音视频),需创建会话,设置会话类别为后台播放,并激活会话.

// 为确保程序运行时会执行到以下设置音视频会话(后台播放会话)代码,所以放在didFinishLaunchingWithOptions方法中执行
// 1.创建会话
AVAudioSession *session = [AVAudioSession sharedInstance];

// 2.设置类别为后台播放 AVAudioSessionCategoryPlayback: 类别为后台播放,该常量字符串在AVAudioSession.h中
[session setCategory:AVAudioSessionCategoryPlayback error:nil];

// 3.激活会话
[session setActive:YES error:nil];

return YES;
```

- 设置锁屏界面显示的内容步骤
- 获取锁屏中心
MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
- 设置锁屏中心要展示的信息,通过设置锁屏中心nowPlayingInfo属性设置,该属性是字典
- 将设置的字典信息赋给nowPlayingInfo属性
playingInfoCenter.nowPlayingInfo = playingInfoDict;
- 让应用程序开启远程事件
[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
```objectivec
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

// 3.6 将设置的字典信息赋给nowPlayingInfo属性
playingInfoCenter.nowPlayingInfo = playingInfoDict;

// SINGLE: 4.让应用程序开启远程事件
[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}
```

---
## 12.实现锁屏锁屏歌词展示
### 绘制锁屏封面和歌词
- 将锁屏的封面图片和歌词重新绘制,生成新图片,在显示到显示歌手图标的UIImageView上

```objectivec
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
CGFloat titleH = 32;

// 4.3.1 绘制上一句歌词和下一句歌词
// SINGLE: 设置绘制文字居中
NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
paragraphStyle.alignment = NSTextAlignmentCenter;
NSDictionary *otherAttr = @{
NSFontAttributeName : [UIFont systemFontOfSize:18],
NSForegroundColorAttributeName : [UIColor yellowColor],
NSParagraphStyleAttributeName : paragraphStyle
};
// 绘制上一句和下一句歌词(绘制到图片底部)
[previousLrcLine.name drawInRect:CGRectMake(0, currentImage.size.height - titleH * 3, currentImage.size.width, titleH) withAttributes:otherAttr];
[nextLrcLine.name drawInRect:CGRectMake(0, currentImage.size.height - titleH, currentImage.size.width, titleH) withAttributes:otherAttr];

// 4.3.2 绘制当前行歌词文字
NSDictionary *currentAttr = @{
NSFontAttributeName : [UIFont systemFontOfSize:24],
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
```
