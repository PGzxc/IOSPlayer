//
//  HMPlayingViewController.m
//  黑马音乐
//
//  Created by piglikeyoung on 15/5/24.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//

#import "HMPlayingViewController.h"
#import "UIView+Extension.h"
#import "HMAudioTool.h"
#import "HMMusicsTool.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+Extension.h"
#import "HMLrcView.h"
#import "HMMusicsTool.h"
#import <MediaPlayer/MediaPlayer.h>

@interface HMPlayingViewController () <AVAudioPlayerDelegate>
/**
 * 退出
 */
- (IBAction)exit;
/**
 *  歌曲大图
 */
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
/**
 *  歌曲名称
 */
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
/**
 *  歌手名称
 */
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;

/**
 *  当前正在播放的音乐
 */
@property (nonatomic, strong) HMMusic *playingMusic;

/**
 *  当前播放器
 */
@property (nonatomic, strong) AVAudioPlayer *player;
/**
 *  时长
 */
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

/**
 *  定时器
 */
@property (strong , nonatomic) NSTimer *currentTimeTimer;

/**
 *  滑块
 */
@property (weak, nonatomic) IBOutlet UIButton *slider;
/**
 *  显示时间小方块
 */
@property (weak, nonatomic) IBOutlet UIButton *currentTimeView;
/**
 *  蓝色播放进度
 */
@property (weak, nonatomic) IBOutlet UIView *progressView;

/**
 *  监听进度条的点击手势
 */
- (IBAction)onProgressBgTap:(id)sender;

/**
 *  监听滑块的滑动
 */
- (IBAction)onPanSlider:(UIPanGestureRecognizer *)sender;

/**
 *  播放/暂停按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;

/**
 *  上一首
 */
- (IBAction)previous;

/**
 *  下一首
 */
- (IBAction)next;

/**
 *  播放或暂停
 */
- (IBAction)playOrPause;


@property (weak, nonatomic) IBOutlet HMLrcView *lrcView;

/**
 *  歌词显示的定时器，不用NSTimer，因为那个太慢，这个刷帧比较快
 */
@property (nonatomic, strong) CADisplayLink *lrcTimer;


@end

@implementation HMPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentTimeView.layer.cornerRadius = 8;
}

#pragma mark - 公共方法
- (void)show {
    
    // 0.判断是否切换歌曲
    if (self.playingMusic != [HMMusicsTool returnPlayingMusic]) {
        // 重置数据
        [self resetPlayingMusic];
    }
    // 1.拿到window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 2.设置当前控制器的frame
    //self.view.y = window.bounds.size.height;
    self.view.frame = window.bounds;
    
    // 3.将当前控制器的View添加到window上
    [window addSubview:self.view];
    self.view.hidden = NO;
    
    // 禁用交互功能
    window.userInteractionEnabled = NO;
    
    // 4.执行动画，让控制器的View从下面转出来
    [UIView animateWithDuration:1 animations:^{
        // 执行动画
        self.view.y = 0;
    } completion:^(BOOL finished) {
        // 开启交互
        window.userInteractionEnabled = YES;
        // 开始播放
        [self startPlayingMusic];
    }];
}

#pragma mark - 全局内部方法
// 开始播放
- (void)startPlayingMusic
{
    // 执行动画完毕, 开始播放音乐
    // 1.取出当前正在播放的音乐模型
    HMMusic *music = [HMMusicsTool returnPlayingMusic];
    
    // 2.播放音乐
    self.player = [HMAudioTool playMusic:music.filename];
    self.player.delegate = self;
    // 记录当前正在播放的音乐
    self.playingMusic = [HMMusicsTool returnPlayingMusic];
    
    // 3.设置其他属性
    // 设置歌手
    self.singerLabel.text = music.singer;
    // 歌曲名称
    self.songLabel.text = music.name;
    // 背景大图
    self.iconView.image = [UIImage imageNamed:music.icon];
    // 设置总时长
    self.durationLabel.text = [self strWithTimeInterval:self.player.duration];
    
    // 4.开启定时器
    [self addProgressTimer];
    [self addLrcTimer];
    
    // 5.设置播放按钮状态
    self.playOrPauseButton.selected = YES;
    
    // 6.切换歌词（加载新的歌词）
    self.lrcView.lrcname = self.playingMusic.lrcname;
    
    // 7.切换锁屏界面的歌曲
    [self updateLockedScreenMusic];

}

// 将秒转换为指定格式的字符串
- (NSString *)strWithTimeInterval:(NSTimeInterval)interval
{
    int m = interval / 60;
    int s = (int)interval % 60;
    return [NSString stringWithFormat:@"%02d: %02d", m , s];
}


// 重置数据
- (void)resetPlayingMusic {
    
    // 设置歌手
    self.singerLabel.text = nil;
    // 歌曲名称
    self.songLabel.text = nil;
    // 背景大图
    self.iconView.image = [UIImage imageNamed:@"play_cover_pic_bg"];
//    self.iconView.clipsToBounds = YES;// 超出部分减掉
    
    // 停止当前正在播放的歌曲
    [HMAudioTool stopMusic:self.playingMusic.filename];
    self.player = nil;
    
    // 设置播放按钮状态
    self.playOrPauseButton.selected = NO;
}

- (IBAction)exit {
    
    // 移除定时器
    [self removeProgressTimer];
    [self removeLrcTimer];
    
    // 1.拿到window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 禁用交互功能
    window.userInteractionEnabled = NO;
    
    // 2.执行退出动画
    [UIView animateWithDuration:1 animations:^{
        self.view.y = window.bounds.size.height;
    } completion:^(BOOL finished) {
        // 隐藏控制器的view
        self.view.hidden = YES;
        
        // 开启交互
        window.userInteractionEnabled = YES;
    }];
}

- (IBAction)lyricOrPic:(UIButton *)sender {
    if (self.lrcView.isHidden) { // 显示歌词，盖住图片
        self.lrcView.hidden = NO;
        sender.selected = YES;
        
        [self addLrcTimer];
    } else { // 隐藏歌词，显示图片
        self.lrcView.hidden = YES;
        sender.selected = NO;
        
        [self removeLrcTimer];
    }
}

- (IBAction)previous {
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    window.userInteractionEnabled = NO;
    
    // 1.重置当前歌曲
    [self resetPlayingMusic];
    
    // 2.获得下一首歌曲
    [HMMusicsTool setPlayingMusic:[HMMusicsTool previouesMusic]];
    
    // 3.播放下一首
    [self startPlayingMusic];
    
    window.userInteractionEnabled = YES;
}

- (IBAction)next {
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    window.userInteractionEnabled = NO;
    
    // 1.重置当前歌曲
    [self resetPlayingMusic];
    
    // 2.获得下一首歌曲
    [HMMusicsTool setPlayingMusic:[HMMusicsTool nextMusic]];
    
    // 3.播放下一首
    [self startPlayingMusic];
    
    window.userInteractionEnabled = YES;
}

- (IBAction)playOrPause {
    if (self.player.isPlaying) { // 暂停
        self.playOrPauseButton.selected = NO;
        [HMAudioTool pauseMusic:self.playingMusic.filename];
        [self removeProgressTimer];
        [self removeLrcTimer];
    } else { // 继续播放
        self.playOrPauseButton.selected = YES;
        [HMAudioTool playMusic:self.playingMusic.filename];
        [self addProgressTimer];
        [self addLrcTimer];
        
        // 更新锁屏信息
        [self updateLockedScreenMusic];
    }
}


#pragma mark - 定时器处理
/**
 *  开启定时器
 */
- (void)addProgressTimer {
    // 1.判断是否正在播放音乐
    if (self.player.playing == NO) return;
    
    [self removeProgressTimer];
    
    // 保持数据同步
    [self updateCurrentProgress];
    
    // 2.创建定时器
    self.currentTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentProgress) userInfo:nil repeats:YES];
    
    // 3.将定时器添加到事件循环
    [[NSRunLoop mainRunLoop] addTimer:self.currentTimeTimer forMode:NSRunLoopCommonModes];
}

- (void)removeProgressTimer {
    [self.currentTimeTimer invalidate];
    self.currentTimeTimer = nil;
}


/**
 *  更新进度
 */
- (void)updateCurrentProgress
{
    
    // 1.计算进度
    double progress = self.player.currentTime / self.player.duration;
    
    // 2.获取滑块移动的最大距离
    double sliderMaxX = self.view.width - self.slider.width;
    
    // 3.设置滑块移动的位置
    self.slider.x = sliderMaxX * progress;
    
    // 4.设置蓝色进度条的宽度
    self.progressView.width = self.slider.center.x;
    
    // 5.设置滑块的标题
    [self.slider setTitle:[self strWithTimeInterval:self.player.currentTime] forState:UIControlStateNormal];
    
}

/**
 *  添加歌词定时器
 */
- (void)addLrcTimer
{
    // 如果不是正在播放 或者 歌词界面是隐藏的，不添加定时器
    if (self.player.isPlaying == NO || self.lrcView.hidden) return;
    
    [self removeLrcTimer];
    
    // 保证定时器的工作是及时的
    [self updateLrc];
    
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

/**
 *  移除歌词定时器
 */
- (void)removeLrcTimer
{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}

/**
 *  更新歌词
 */
- (void)updateLrc
{
    self.lrcView.currentTime = self.player.currentTime;
}


#pragma mark - 内部控制器方法

- (void) updateLockedScreenMusic {
    
    // 1.播放信息中心
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    
    // 2.初始化播放信息
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    // 专辑名称
    info[MPMediaItemPropertyAlbumTitle] = self.playingMusic.name;
    // 歌手
    info[MPMediaItemPropertyArtist] = self.playingMusic.singer;
    // 歌曲名称
    info[MPMediaItemPropertyTitle] = self.playingMusic.name;
    // 设置图片
    info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:self.playingMusic.icon]];
    // 设置持续时间（歌曲的总时间）
    info[MPMediaItemPropertyPlaybackDuration] = @(self.player.duration);
    // 设置当前播放进度
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(self.player.currentTime);
    
    // 3.切换播放信息
    center.nowPlayingInfo = info;
    
    // 远程控制事件 Remote Control Event
    // 加速计事件 Motion Event
    // 触摸事件 Touch Event
    
    // 4.开始监听远程控制事件
    // 4.1.成为第一响应者（必备条件）
    [self becomeFirstResponder];
    // 4.2.开始监控
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}


/**
 *  点击了进度条背景，就从那里开始播放
 */
- (void)onProgressBgTap:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:sender.view];
    
    // 切换歌曲的当前播放时间
    self.player.currentTime = (point.x / sender.view.width) * self.player.duration;
    
    [self updateCurrentProgress];
}

/**
 *  拖动滑块
 */
- (void)onPanSlider:(UIPanGestureRecognizer *)sender {
    
    // 1.获得当前拖拽的位置
    // 获取到滑块平移的位置
    CGPoint point = [sender translationInView:sender.view];
    [sender setTranslation:CGPointZero inView:sender.view];
    
    
    // 2.将滑块移动到拖拽的位置
    // 累加平移位置
    self.slider.x += point.x;
    if (self.slider.x < 0) {
        self.slider.x = 0;
    }
    
    
    // 计算当前拖拽到的指定位置
    double progress = self.slider.x / self.slider.superview.width;
    NSTimeInterval time = progress * self.player.duration;
    
    // 4.设置拖拽时滑块的标题
    [self.slider setTitle:[self strWithTimeInterval:time] forState:UIControlStateNormal];
    
    // 5.设置显示进度的方块的内容
    [self.currentTimeView setTitle:[self strWithTimeInterval:time] forState:UIControlStateNormal];
    
    // 6.设置显示进度的方块的frame
    self.currentTimeView.x = self.slider.x;
    self.currentTimeView.y = self.currentTimeView.superview.height - self.currentTimeView.height - 10;
    
    // 3.判断当前收拾的状态
    // 如果是开始拖拽就停止定时器, 如果结束拖拽就开启定时器
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        // 显示进度的方块
        self.currentTimeView.hidden = NO;
        
        // 开始拖拽
        NSLog(@"开始拖拽, 停止定时器");
        [self removeProgressTimer];
        
    }else if (sender.state == UIGestureRecognizerStateEnded)
    {
        // 隐藏显示进度的方块
        self.currentTimeView.hidden = YES;
        
        self.player.currentTime  = time;
        
        // 结束拖拽
        NSLog(@"结束拖拽, 开启定时器");
        [self addProgressTimer];
        
        
    }

}

#pragma mark - AVAudioPlayerDelegate
/**
 *  播放器播放完毕后就会调用
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self next];
}

/**
 *  当播放器遇到中断的时候调用（比如来电）
 */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    if (self.player.isPlaying) {
        [self playOrPause];
    }
}

/**
 *  当中断结束的时候调用
 */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    
}

#pragma mark - 远程控制事件监听
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    //    event.type; // 事件类型
    //    event.subtype; // 事件的子类型
    //    UIEventSubtypeRemoteControlPlay                 = 100,
    //    UIEventSubtypeRemoteControlPause                = 101,
    //    UIEventSubtypeRemoteControlStop                 = 102,
    //    UIEventSubtypeRemoteControlTogglePlayPause      = 103,
    //    UIEventSubtypeRemoteControlNextTrack            = 104,
    //    UIEventSubtypeRemoteControlPreviousTrack        = 105,
    //    UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
    //    UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
    //    UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
    //    UIEventSubtypeRemoteControlEndSeekingForward    = 109,
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playOrPause];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous];
            
        default:
            break;
    }
}

@end
