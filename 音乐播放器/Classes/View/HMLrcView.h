//
//  HMLrcView.h
//  02-黑马音乐
//
//  Created by apple on 14-8-8.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "DRNRealTimeBlurView.h"

@interface HMLrcView : DRNRealTimeBlurView
/**
 *  歌词的文件名
 */
@property (nonatomic, copy) NSString *lrcname;

@property (nonatomic, assign) NSTimeInterval currentTime;
@end
