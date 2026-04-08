#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (UUChatCategory)

@property (nonatomic) CGFloat uu_left;
@property (nonatomic) CGFloat uu_top;
@property (nonatomic) CGFloat uu_right;
@property (nonatomic) CGFloat uu_bottom;
@property (nonatomic) CGFloat uu_width;
@property (nonatomic) CGFloat uu_height;
@property (nonatomic) CGFloat uu_centerX;
@property (nonatomic) CGFloat uu_centerY;

@end

@interface UIScreen (UUChatCategory)

+ (CGFloat)uu_screenWidth;
+ (CGFloat)uu_screenHeight;
+ (CGRect)uu_screenBounds;
+ (CGSize)uu_screenSize;

@end

@interface UIImage (UUChatCategory)

+ (nullable instancetype)uu_imageWithName:(NSString *)imageName;
+ (UIImage *)uu_imageWithColor:(UIColor *)color;
+ (nullable UIImage *)uu_symbolImageNamed:(NSString *)symbolName
                                 pointSize:(CGFloat)pointSize
                                    weight:(UIImageSymbolWeight)weight
                                 tintColor:(UIColor *)tintColor API_AVAILABLE(ios(13.0));

@end

@interface NSString (UUChatCategory)

- (CGSize)uu_sizeWithFont:(UIFont *)font;
- (CGSize)uu_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

@end

@interface UIResponder (UUChatCategory)

- (nullable __kindof UIResponder *)uu_findNextResponderInClass:(Class)responderClass;
- (nullable __kindof UIResponder *)uu_findNextResonderInClass:(Class)responderClass;

@end

NS_ASSUME_NONNULL_END
