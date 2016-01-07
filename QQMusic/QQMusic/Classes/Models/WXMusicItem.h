//
//  WXMusicItem.h
//  QQMusic
//
//  Created by 李伟雄 on 16/1/7.
//  Copyright © 2016年 Liwx. All rights reserved.
//

#import <Foundation/Foundation.h>

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
