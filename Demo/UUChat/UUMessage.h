//
//  UUMessage.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    UUMessageTypeText     = 0 , // 文字
    UUMessageTypePicture  = 1 , // 图片
    UUMessageTypeVoice    = 2   // 语音
} MessageType;


typedef enum {
    UUMessageFromMe    = 100,   // 自己发的
    UUMessageFromOther = 101    // 别人发得
} MessageFrom;


@interface UUMessage : NSObject

@property (nonatomic, copy) NSString *strIcon;
@property (nonatomic, copy) NSString *strId;
@property (nonatomic, copy) NSString *strTime;
@property (nonatomic, copy) NSString *strName;

@property (nonatomic, copy) NSString *strContent;
@property (nonatomic, copy) UIImage  *picture;
@property (nonatomic, copy) NSData   *voice;
@property (nonatomic, copy) NSString *strVoiceTime;

@property (nonatomic, assign) MessageType type;
@property (nonatomic, assign) MessageFrom from;

@property (nonatomic, assign) BOOL showDateLabel;

- (void)setWithDict:(NSDictionary *)dict;

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end;

@end
