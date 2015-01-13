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

- (void)populateRandomDataSource {
    self.dataSource = [NSMutableArray array];
    [self.dataSource addObjectsFromArray:[self additems:2]];
}

- (void)addRandomItemsToDataSource:(NSInteger)number{

    for (int i=0; i<number; i++) {
        [self.dataSource insertObject:[[self additems:1] firstObject] atIndex:0];
    }
}

- (void)addSpecifiedItem:(NSDictionary *)dic
{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
  
    NSString *URLStr = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    [dataDic setObject:@1 forKey:@"from"];
    [dataDic setObject:[[NSDate date] description] forKey:@"strTime"];
    [dataDic setObject:@"Hello,sister" forKey:@"strName"];
    [dataDic setObject:URLStr forKey:@"strIcon"];
    
    [message setWithDict:dataDic];
    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
    messageFrame.showTime = message.showDateLabel;
    [messageFrame setMessage:message];
    
    if (message.showDateLabel) {
        previousTime = dataDic[@"strTime"];
    }
    [self.dataSource addObject:messageFrame];
}

static NSString *previousTime = nil;

- (NSArray *)additems:(NSInteger)number
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (int i=0; i<number; i++) {
        
        UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
        UUMessage *message = [[UUMessage alloc] init];
        NSDictionary *dataDic = [self getDic];
        
        [message setWithDict:dataDic];
        [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
        messageFrame.showTime = message.showDateLabel;
        [messageFrame setMessage:message];
        
        if (message.showDateLabel) {
            previousTime = dataDic[@"strTime"];
        }
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
            [dictionary setObject:[self randomString] forKey:@"strContent"];
            break;
        case 1:// picture
            [dictionary setObject:[UIImage imageNamed:@"haha.jpeg"] forKey:@"picture"];
            break;
//            case 2:// audio
//                [dictionary setObject:@"" forKey:@"voice"];
//                [dictionary setObject:@"" forKey:@"strVoiceTime"];
//                break;
        default:
            break;
    }
    static int dateNum = 10;
    NSString *URLStr = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/chongwu16.jpg";
    NSDate *date = [[NSDate date]dateByAddingTimeInterval:arc4random()%1000*(dateNum++) ];
    [dictionary setObject:[NSNumber numberWithInt:0] forKey:@"from"];
    [dictionary setObject:[NSNumber numberWithInt:randomNum] forKey:@"type"];
    [dictionary setObject:[date description] forKey:@"strTime"];
    [dictionary setObject:@"Hello,Boss" forKey:@"strName"];
    [dictionary setObject:URLStr forKey:@"strIcon"];
    
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
