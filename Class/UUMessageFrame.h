#define ChatMargin 14       //间隔
#define ChatIconWH 42       //头像宽高height、width
#define ChatPicWH 188       //图片最大宽高
#define ChatContentW 236    //内容最大宽度

#define ChatContentTopBottom 12 //文本内容与按钮上边缘间隔
#define ChatContentBiger 18      //文本内容带角的一端
#define ChatContentSmaller 18    //文本内容不带角的一端

#define ChatTimeFont [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightSemibold] //时间字体
#define ChatContentFont [UIFont systemFontOfSize:15 weight:UIFontWeightRegular]          //内容字体

#import <UIKit/UIKit.h>

@class UUMessage;

@interface UUMessageFrame : NSObject

@property (nonatomic, assign, readonly) CGRect timeF;
@property (nonatomic, assign, readonly) CGRect iconF;
@property (nonatomic, assign, readonly) CGRect nameF;
@property (nonatomic, assign, readonly) CGRect contentF;

@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, strong) UUMessage *message;

@property (nonatomic, assign) BOOL showTime;
@property (nonatomic, assign) CGFloat layoutWidth;

@end
