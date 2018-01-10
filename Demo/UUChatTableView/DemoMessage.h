//
//  DemoMessage.h
//  UUChatTableView
//
//  Created by XcodeYang on 10/01/2018.
//  Copyright © 2018 uyiuyao. All rights reserved.
//

#import "UUMessage.h"

@interface DemoMessage : NSObject <UUMessage>

@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, copy) NSString *userId;

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end;

@end
