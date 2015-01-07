//
//  ChatModel.m
//  UUChatTableView
//
//  Created by shake on 15/1/6.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "ChatModel.h"

#import "UUMessage.h"
#import "UUMessageFrame.h"

@implementation ChatModel

- (id)init {
    
    if (self = [super init]) {
        
    }
    return self;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

- (void)populateDataSource {
    self.dataSource = (NSMutableArray *)[self add20items];
}

- (void)addItemsToDataSource {
    
    [self.dataSource addObjectsFromArray:[self add20items]];
}

static NSString *previousTime = nil;

- (NSArray *)add20items
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (int i=0; i<20; i++) {
        
        UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
        UUMessage *message = [[UUMessage alloc] init];
        NSDictionary *dataDic = [self getDic];
        
        [message setWithDict:dataDic];
        [message minuteOffSetStart:previousTime end:dataDic[@"createTime"]];
        messageFrame.showTime = message.showDateLabel;
        [messageFrame setMessage:message];
        
        if (message.showDateLabel) {
            previousTime = dataDic[@"createTime"];
        }
            [result addObject:messageFrame];
        

        [result addObject:messageFrame];
    }
    return result;
}


- (NSDictionary *)getDic
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int randomNum = arc4random()%2;
    switch (randomNum) {
        case 0:// text
            [dictionary setObject:[self randomString] forKey:@"body"];
            break;
        case 1:// picture
            [dictionary setObject:[UIImage imageNamed:@"haha.jpeg"] forKey:@"body"];
            break;
//            case 2:// audio
//                [dictionary setObject:@"" forKey:@"body"];
//                [dictionary setObject:@"" forKey:@"time"];
//                break;
        default:
            break;
    }
    [dictionary setObject:[NSNumber numberWithInt:0] forKey:@"from"];
    [dictionary setObject:[NSNumber numberWithInt:randomNum] forKey:@"type"];
    
    return dictionary;
}


- (NSString *)randomString {
    
    NSString *lorumIpsum = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non quam ac massa viverra semper. Maecenas mattis justo ac augue volutpat congue. Maecenas laoreet, nulla eu faucibus gravida, felis orci dictum risus, sed sodales sem eros eget risus. Morbi imperdiet sed diam et sodales. Vestibulum ut est id mauris ultrices gravida. Nulla malesuada metus ut erat malesuada, vitae ornare neque semper. Aenean a commodo justo, vel placerat odio";
    
    NSArray *lorumIpsumArray = [lorumIpsum componentsSeparatedByString:@" "];
    
    int r = arc4random() % [lorumIpsumArray count];
    r = MAX(3, r); // no less than 3 words
    NSArray *lorumIpsumRandom = [lorumIpsumArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, r)]];
    
    return [NSString stringWithFormat:@"%@!!", [lorumIpsumRandom componentsJoinedByString:@" "]];
}

@end
