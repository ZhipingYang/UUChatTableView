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
- (void)chatCell:(UUMessageCell *)cell headImageDidClick:(NSString *)userId;
@end


@interface UUMessageCell : UITableViewCell

@property (nonatomic, strong) UUMessageFrame *messageFrame;

@property (nonatomic, weak) id<UUMessageCellDelegate> delegate;

@end

