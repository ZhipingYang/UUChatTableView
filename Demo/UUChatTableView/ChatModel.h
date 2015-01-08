//
//  ChatModel.h
//  UUChatTableView
//
//  Created by shake on 15/1/6.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatModel : NSObject

@property (nonatomic, strong) NSMutableArray *dataSource;

- (void)populateRandomDataSource;

- (void)addRandomItemsToDataSource:(NSInteger)number;

- (void)addSpecifiedItem:(NSDictionary *)dic;

@end
