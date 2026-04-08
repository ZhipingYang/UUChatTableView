#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UUInputActionItem;
@class UUInputFunctionView;

@interface UUInputActionItem : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *systemImageName;

+ (instancetype)actionItemWithIdentifier:(NSString *)identifier
                                   title:(NSString *)title
                         systemImageName:(NSString *)systemImageName;

@end

@protocol UUInputFunctionViewDelegate <NSObject>
@optional

- (void)inputFunctionView:(UUInputFunctionView *)inputFunctionView didSendText:(NSString *)text;
- (void)inputFunctionView:(UUInputFunctionView *)inputFunctionView didSendImage:(UIImage *)image;
- (void)inputFunctionView:(UUInputFunctionView *)inputFunctionView didSendVoiceData:(NSData *)voiceData duration:(NSInteger)duration;
- (void)inputFunctionView:(UUInputFunctionView *)inputFunctionView didSelectCustomActionItem:(UUInputActionItem *)actionItem;
- (void)inputFunctionView:(UUInputFunctionView *)inputFunctionView didChangePreferredHeight:(CGFloat)preferredHeight animated:(BOOL)animated;

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message;
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image;
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second;

@end

@interface UUInputFunctionView : UIView

@property (nonatomic, strong) UIButton *btnSendMessage;
@property (nonatomic, strong) UIButton *btnChangeVoiceState;
@property (nonatomic, strong) UIButton *btnVoiceRecord;
@property (nonatomic, strong) UITextView *textViewInput;
@property (nonatomic, assign) BOOL isAbleToSendTextMessage;
@property (nonatomic, weak, nullable) id<UUInputFunctionViewDelegate> delegate;
@property (nonatomic, copy) NSArray<UUInputActionItem *> *customActionItems;
@property (nonatomic, assign, readonly) CGFloat preferredHeight;

- (void)updatePrimaryActionForEmptyTextState:(BOOL)isTextEmpty;
- (void)changeSendBtnWithPhoto:(BOOL)isPhoto;
- (void)clearTextInput;

@end

NS_ASSUME_NONNULL_END
