//
//  WXLrcScrollView.h
//  QQMusic
//
//  Created by 李伟雄 on 16/1/8.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXLrcScrollView : UIScrollView

/** 当前播放的时间 */
@property (nonatomic, assign) NSTimeInterval currentTime;

/** 歌词文件名 */
@property (nonatomic, strong) NSString *lrcFileName;

@end
