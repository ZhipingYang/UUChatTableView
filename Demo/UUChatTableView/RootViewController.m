//
//  RootViewController.m
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "RootViewController.h"
#import "UUInputFunctionView.h"
#import "MJRefresh.h"
#import "UUMessageCell.h"
#import "ChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"

@interface RootViewController ()<UUInputFunctionViewDelegate,UUMessageCellDelegate>
{
    NSMutableArray *allMessagesFrame;
    NSArray *headInfoArray;
    
    BOOL isMoreData;
    
    MJRefreshHeaderView *tableViewHeader;
    MJRefreshFooterView *tableViewFooter;
}

@property (strong, nonatomic) ChatModel *chatModel;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadBaseViewsAndData];
}

- (void)loadBaseViewsAndData
{
    self.chatModel = [[ChatModel alloc]init];
    [self.chatModel populateDataSource];
    
    UUInputFunctionView *IFView = [[UUInputFunctionView alloc]initWithSuperVC:self];
    IFView.delegate = self;
    [self.view addSubview:IFView];
    
    
}
#pragma mark - InputFunctionViewDelegate
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    
}
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    
}
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    
}

#pragma mark - tableView_delegate_datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[UUMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setMessageFrame:allMessagesFrame[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [allMessagesFrame[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

#pragma mark - cellDelegate
//- (void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId
//{
//    PatientsInfoViewController *info = [[PatientsInfoViewController alloc]init];
//    info.patinetsID = userId;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
//    [self.navigationController pushViewController:info animated:YES];
//}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
