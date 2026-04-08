#import <UIKit/UIKit.h>

@interface UUMessageContentButton : UIButton

@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIView *voiceBackView;
@property (nonatomic, strong) UILabel *second;
@property (nonatomic, strong) UIImageView *voice;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, assign) BOOL isMyMessage;

- (void)benginLoadVoice;
- (void)didLoadVoice;
- (void)stopPlay;

@end
