#import <UIKit/UIKit.h>
#import "UUMessageContentButton.h"

NS_ASSUME_NONNULL_BEGIN

@class UUMessageFrame;
@class UUMessageCell;

@protocol UUMessageCellDelegate <NSObject>
@optional
- (void)messageCell:(UUMessageCell *)cell didTapAvatarForUserIdentifier:(NSString *)userIdentifier;
- (void)chatCell:(UUMessageCell *)cell headImageDidClick:(NSString *)userId;
@end

@interface UUMessageCell : UITableViewCell

@property (nonatomic, strong) UUMessageFrame *messageFrame;
@property (nonatomic, weak, nullable) id<UUMessageCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
