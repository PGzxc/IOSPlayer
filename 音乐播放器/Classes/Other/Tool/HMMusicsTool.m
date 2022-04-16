//
//  HMMusicsTool.m
//  03-黑马音乐
//
//  Created by apple on 14/11/7.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMMusicsTool.h"
#import "MJExtension.h"

@implementation HMMusicsTool

// 所有歌曲
static NSArray *_musics;

// 当前正在播放歌曲
static HMMusic *_playingMusic;

// 获取所有音乐
+ (NSArray *)musics
{
    if (!_musics) {
        _musics = [HMMusic objectArrayWithFilename:@"Musics.plist"];
    }
    return _musics;
}

// 设置当前正在播放的音乐
+ (void)setPlayingMusic:(HMMusic *)music
{
    // 判断传入的音乐模型是否为nil
    // 判断数组中是否包含该音乐模型
    if (!music ||
        ![[self musics] containsObject:music]) {
        return;
    }
    _playingMusic = music;
}

// 返回当前正在播放的音乐
+ (HMMusic *)returnPlayingMusic
{
    return _playingMusic;
}

// 获取下一首
+ (HMMusic *)nextMusic
{
    // 1.获取当前播放的索引
    NSArray *_musics=[self musics];
    NSUInteger currentIndex = [_musics indexOfObject:_playingMusic];
    // 2.计算下一首的索引
    NSInteger nextIndex = currentIndex + 1;
    // 3.越界处理
    if (nextIndex >= [[self musics] count]) {
        nextIndex = 0;
    }
    // 4.取出下一首的模型返回
    return [self musics][nextIndex];
}

// 获取上一首
+ (HMMusic *)previouesMusic
{
    // 1.获取当前播放的索引
    NSUInteger currentIndex = [[self musics] indexOfObject:_playingMusic];
    // 2.计算上一首的索引
    NSInteger perviouesIndex = currentIndex - 1;
    // 3.越界处理
    if (perviouesIndex < 0) {
        perviouesIndex = [[self musics] count] - 1;
    }
    // 4.取出下一首的模型返回
    return [self musics][perviouesIndex];
}
@end
