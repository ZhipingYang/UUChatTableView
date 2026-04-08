#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UUVoiceRecordingHUDView : UIView

- (void)presentInView:(UIView *)view;
- (void)updateWithDuration:(NSTimeInterval)duration level:(CGFloat)level;
- (void)setCancelling:(BOOL)cancelling;
- (void)dismissAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
