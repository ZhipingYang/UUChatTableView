//
//  UUMessageFrame.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "UUChatCategory.h"

@implementation UUMessageFrame

- (void)setMessage:(id<UUMessage>)message {
	_message = message;
    
    CGFloat const screenW = [UIScreen uu_screenWidth];
    
    // 1、计算时间的位置
    if (_message.date.length > 0) {
		CGSize timeSize = [_message.date uu_sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(300, 100)];
        _timeFrame = CGRectMake((screenW - timeSize.width) / 2, ChatMargin, timeSize.width, timeSize.height);
    } else {
		_timeFrame = CGRectZero;
	}
    
    // 2、计算头像位置
	CGFloat const iconX = _message.from == UUMessageFromOther ? ChatMargin : (screenW - ChatMargin - ChatIconWH);
    _iconFrame = CGRectMake(iconX, CGRectGetMaxY(_timeFrame) + ChatMargin, ChatIconWH, ChatIconWH);
    
    // 3、计算ID位置
	CGSize nameSize = [_message.nickName uu_sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(ChatIconWH+ChatMargin, 50)];
    _nameFrame = CGRectMake(iconX-ChatMargin/2.0, CGRectGetMaxY(_iconFrame) + ChatMargin/2.0, ChatIconWH+ChatMargin, nameSize.height);
    
    // 4、计算内容位置
    CGFloat contentX = CGRectGetMaxX(_iconFrame) + ChatMargin;
   
    //根据种类分
    CGSize contentSize;
    switch (_message.type) {
        case UUMessageTypeText:
			contentSize = [_message.text uu_sizeWithFont:ChatContentFont constrainedToSize:CGSizeMake(MAX(ChatContentW, screenW*0.6), CGFLOAT_MAX)];
			contentSize.height = MAX(contentSize.height, 30);
			contentSize.width = MAX(contentSize.width, 40);
            break;
        case UUMessageTypePicture:
            contentSize = CGSizeMake(ChatPicWH, ChatPicWH);
            break;
        case UUMessageTypeVoice:
            contentSize = CGSizeMake(120, 35);
            break;
        default:
            break;
    }
    if (_message.from == UUMessageFromMe) {
        contentX = screenW - (contentSize.width + ChatContentBiger + ChatContentSmaller + ChatMargin + ChatIconWH + ChatMargin);
    }
    _contentFrame = CGRectMake(contentX, CGRectGetMinY(_iconFrame) + 5, contentSize.width + ChatContentBiger + ChatContentSmaller, contentSize.height + ChatContentTopBottom * 2);
    
    _cellHeight = MAX(CGRectGetMaxY(_contentFrame), CGRectGetMaxY(_nameFrame))  + ChatMargin;
}

@end
