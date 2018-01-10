//
//  UUMessageCell.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessage.h"

NS_ASSUME_NONNULL_BEGIN
@class UUMessageFrame;
@class UUMessageCell;

@protocol UUMessageCellDelegate <NSObject>
@optional

/**
 cell的头像点击

 @param cell 当前头像的cell
 @param message cell的承载信息 model
 */
- (void)chatCell:(UUMessageCell *)cell headImageDidClick:(id<UUMessage>)message;

@end


@interface UUMessageCell : UITableViewCell

@property (nonatomic, strong) UUMessageFrame *messageFrame;

@property (nonatomic, weak) id<UUMessageCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
