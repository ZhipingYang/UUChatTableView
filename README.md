UUChatTableView
===============

Cocoa UI component for chat bubbles with text, images and audio support

## GIF 动画演示
![Flipboard playing multiple GIFs](https://github.com/ZhipingYang/UUChatTableView/raw/master/Demo/UUChatTableViewTests/ChatTableView.gif)

## 截图 - ScreenShot
![图片一](https://github.com/ZhipingYang/UUChatTableView/raw/master/Demo/UUChatTableViewTests//ScreenShot/QQ20150113-5.jpg) ![图片一](https://github.com/ZhipingYang/UUChatTableView/raw/master/Demo/UUChatTableViewTests//ScreenShot/QQ20150113-4.jpg)
### 群聊（GroupChat）效果图（新添UI细节）
![图片三](https://github.com/ZhipingYang/DataResource/raw/master/UUChat/IMG_0052.jpg)  
![图片三](https://github.com/ZhipingYang/DataResource/raw/master/UUChat/IMG_0054.jpg)  
##使用类介绍 - Introduce

[类名](https://github.com/ZhipingYang/UUChatTableView/tree/master/UUChat) | 作用及用法
----- | -----
[UUMessage](https://github.com/ZhipingYang/UUChatTableView/blob/master/UUChat/UUMessage.h) | 内容数据Model，储存文字、语音、头像、图片、时间等等
[UUMessageFrame](https://github.com/ZhipingYang/UUChatTableView/blob/master/UUChat/UUMessageFrame.h) | cell的model，设置气泡聊天的布局
[UUMessageCell](https://github.com/ZhipingYang/UUChatTableView/blob/master/UUChat/UUMessageContentButton.h) | 呈现UI，并做cell的事件处理（语音、图片、头像点击）
[UUMessageContentButton](https://github.com/ZhipingYang/UUChatTableView/blob/master/UUChat/) | 气泡内容的封装及copy功能
[UUInputFunctionView](https://github.com/ZhipingYang/UUChatTableView/blob/master/UUChat/UUInputFunctionView.h) | tableView底部的视图，相当于ToolBar
[UUImageAvatarBrowser](https://github.com/ZhipingYang/UUChatTableView/blob/master/UUChat/UUImageAvatarBrowser.h) | 放大图片功能，其实这是障眼法[详细查看](https://github.com/ZhipingYang/UUChatTableView/blob/master/UUChat/UUImageAvatarBrowser.m)
[UUAVAudioPlayer](https://github.com/ZhipingYang/UUChatTableView/blob/master/UUChat/UUAVAudioPlayer.h) | 语音功能封装，实现本地和线上URL播放，缺点是还没有做像[SDWebImage](https://github.com/rs/SDWebImage)那样的本地缓存
[UUProgressHUD](https://github.com/ZhipingYang/UUChatTableView/blob/master/UUChat/UUProgressHUD.h) | Window层上得HUD，功能简易

第三方库 | 说明
----- | -----
[MJRefresh](https://github.com/CoderMJLee/MJRefresh) | 下拉加载更多聊天记录
[AFNetworking](https://github.com/AFNetworking/AFNetworking) | 仅使用UIKit+AFNetworking，类似 [SDWebImage](https://github.com/rs/SDWebImage)
VoiceLib | 忘记了来自哪里的，找半天没有找到。语音录入及格式转化成MP3

##使用方法 - Usage
声明一下| 
----- | -----
当前的数据是在固定模式下随机模拟的，不包含用户输入的所有可能性|
有不习惯`Xib编程`的有问题可以[问我](https://github.com/ZhipingYang/UUChatTableView/issues/new),以前我因为不会而不想去改变 | 
我还没有去试iOS6下得适配，要是你测试过油问题可以修改提交或者[告诉我](https://github.com/ZhipingYang/UUChatTableView/issues/new) | 
有人提到群聊功能，只需要在getDic方法添加其他人信息即可[点击查看](https://github.com/ZhipingYang/UUChatTableView/blob/master/Demo/UUChatTableView/ChatModel.m#L78)|
感谢[丁南](https://github.com/ijinmao)修复语音播放及其他的一些bug|


####添加代理
 
<h5 id="precode">UUInputFunctionViewDelegate</h5>
	// 返回文字内容
	- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message;
	// 返回图片数据
	- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image;
	// 返回语音数据和录音时长
	- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second;
	
<h5 id="precode">UUMessageCellDelegate</h5>
	//cell的头像点击
	- (void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId;
	//图片点击可有可无
	- (void)cellContentDidClick:(UUMessageCell *)cell image:(UIImage *)contentImage;



