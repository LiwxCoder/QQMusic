//
//  WXLrcScrollView.h
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXLrcLabel;

@interface WXLrcScrollView : UIScrollView

/** 主界面中间歌词的Label,传递过来让内部对其进行赋值,如设置歌词文字和当前行歌词播放进度 */
@property (nonatomic, weak) WXLrcLabel *lrcLabel;

/** 当前播放的时间 */
@property (nonatomic, assign) NSTimeInterval currentTime;

/** 当前播放器的播放总时间*/
@property (nonatomic ,assign) NSTimeInterval duration;

/** 歌词文件名 */
@property (nonatomic, strong) NSString *lrcFileName;

@end
