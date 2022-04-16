//
//  HMMusicCell.h
//  黑马音乐
//
//  Created by piglikeyoung on 15/5/31.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HMMusic;

@interface HMMusicCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) HMMusic *music;
@end
