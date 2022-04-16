//
//  HMMusicsTool.h
//  03-黑马音乐
//
//  Created by apple on 14/11/7.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMMusic.h"

@interface HMMusicsTool : NSObject
// 获取所有音乐
+ (NSArray *)musics;

// 设置当前正在播放的音乐
+ (void)setPlayingMusic:(HMMusic *)music;

// 返回当前正在播放的音乐
+ (HMMusic *)returnPlayingMusic;

// 获取下一首
+ (HMMusic *)nextMusic;

// 获取上一首
+ (HMMusic *)previouesMusic;

@end
