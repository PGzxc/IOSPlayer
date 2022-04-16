//
//  HMLrcCell.h
//  黑马音乐
//
//  Created by piglikeyoung on 15/5/31.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HMLrcLine;

@interface HMLrcCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) HMLrcLine *lrcLine;

@end
