#import <UIKit/UIKit.h>

@class UUMessageFrame;

@interface UUDemoChatDataSource : NSObject

@property (nonatomic, copy, readonly) NSArray<UUMessageFrame *> *dataSource;
@property (nonatomic, assign, readonly, getter=isGroupConversation) BOOL groupConversation;
@property (nonatomic, assign) CGFloat layoutWidth;

- (instancetype)initWithLayoutWidth:(CGFloat)layoutWidth;
- (void)reloadConversationWithGroupMode:(BOOL)isGroupMode;
- (void)prependHistoryMessages:(NSInteger)count;
- (void)appendTextMessage:(NSString *)text;
- (void)appendPictureMessage:(UIImage *)image;
- (void)appendVoiceMessage:(NSData *)voice duration:(NSInteger)duration;

@end
