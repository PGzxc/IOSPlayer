//
//  JHMusicsViewController.m
//  黑马音乐
//
//  Created by piglikeyoung on 15/5/24.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//

#import "HMMusicsViewController.h"
#import "MJExtension.h"
#import "HMMusic.h"
#import "UIImage+NJ.h"
#import "Colours.h"
#import "HMPlayingViewController.h"
#import "HMMusicsTool.h"
#import "HMMusicCell.h"

@interface HMMusicsViewController ()
// 播放界面
@property (nonatomic, strong) HMPlayingViewController *playingVc;
@end

@implementation HMMusicsViewController

#pragma mark - 懒加载
- (HMPlayingViewController *)playingVc
{
    if (!_playingVc) {
        self.playingVc = [[HMPlayingViewController alloc] init];
    }
    return _playingVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.musics.count;
    return [[HMMusicsTool musics] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 1.创建cell
    HMMusicCell *cell = [HMMusicCell cellWithTableView:tableView];
    cell.music = [HMMusicsTool musics][indexPath.row];
    // 2.返回cell
    return cell;
    
}
// 选中某一个行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.主动取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 2.执行segue跳转到播放界面，使用modal的方式打开，关闭控制器会销毁，无法继续播放音乐
    //    [self performSegueWithIdentifier:@"musics2playing" sender:nil];
    
    // 3.设置当前播放的音乐
    HMMusic *music = [HMMusicsTool musics][indexPath.row];
    [HMMusicsTool setPlayingMusic:music];
    
    // 自定义控制器，像modal的方式弹出控制器
    [self.playingVc show];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

@end
