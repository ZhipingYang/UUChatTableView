//
//  UUMessage.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MessageType) {
    UUMessageTypeText = 0 , 	// 文字
    UUMessageTypePicture = 1 , 	// 图片
    UUMessageTypeVoice = 2   	// 语音
};

typedef NS_ENUM(NSInteger, MessageFrom) {
    UUMessageFromMe = 0,   	// 自己发的
    UUMessageFromOther = 1 	// 别人发得
};

NS_ASSUME_NONNULL_BEGIN

@protocol UUMessage <NSObject>

@property (nonatomic, readonly) NSString *nickName;
@property (nonatomic, readonly, nullable) UIImage *avatar;
@property (nonatomic, readonly, nullable) NSString *date;

@property (nonatomic, readonly, nullable) NSString *text;
@property (nonatomic, readonly, nullable) UIImage *image;
@property (nonatomic, readonly, nullable) NSData *voiceData;
@property (nonatomic, readonly, nullable) NSString *voiceText;

@property (nonatomic, readonly) MessageType type;
@property (nonatomic, readonly) MessageFrom from;

@end

NS_ASSUME_NONNULL_END
