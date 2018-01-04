//
//  UUMessageCell.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UUMessageContentButton.h"

@class UUMessageFrame;
@class UUMessageCell;
@protocol UUMessageCellDelegate <NSObject>
@optional
- (void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId;
- (void)cellContentDidClick:(UUMessageCell *)cell image:(UIImage *)contentImage;
@end


@interface UUMessageCell : UITableViewCell

@property (nonatomic, strong) UILabel *labelTime;
@property (nonatomic, strong) UILabel *labelNum;
@property (nonatomic, strong) UIButton *btnHeadImage;

@property (nonatomic, strong) UUMessageContentButton *btnContent;

@property (nonatomic, strong) UUMessageFrame *messageFrame;

@property (nonatomic, weak) id<UUMessageCellDelegate> delegate;

@end

