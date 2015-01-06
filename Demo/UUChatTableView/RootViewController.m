//
//  RootViewController.m
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "RootViewController.h"
#import "MJRefresh.h"

@interface RootViewController ()
{
    NSMutableArray *allMessagesFrame;
    NSArray *headInfoArray;
    
    BOOL isMoreData;
    
    MJRefreshHeaderView *tableViewHeader;
    MJRefreshFooterView *tableViewFooter;
}
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
