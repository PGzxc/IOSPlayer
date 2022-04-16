//
//  HMMusicCell.m
//  黑马音乐
//
//  Created by piglikeyoung on 15/5/31.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//

#import "HMMusicCell.h"
#import "HMMusic.h"
#import "UIImage+NJ.h"
#import "Colours.h"

@implementation HMMusicCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"music";
    HMMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[HMMusicCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    return cell;
}

- (void)setMusic:(HMMusic *)music {
    _music = music;
    
    self.textLabel.text = music.name;
    self.detailTextLabel.text = music.singer;
    self.imageView.image = [UIImage circleImageWithName:music.singerIcon borderWidth:3 borderColor:[UIColor skyBlueColor]];
}

@end
