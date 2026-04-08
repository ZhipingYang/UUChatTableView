#import "UUChatCategory.h"

@implementation UIView (UUChatCategory)

- (CGFloat)uu_left
{
    return self.frame.origin.x;
}

- (void)setUu_left:(CGFloat)uu_left
{
    CGRect frame = self.frame;
    frame.origin.x = uu_left;
    self.frame = frame;
}

- (CGFloat)uu_top
{
    return self.frame.origin.y;
}

- (void)setUu_top:(CGFloat)uu_top
{
    CGRect frame = self.frame;
    frame.origin.y = uu_top;
    self.frame = frame;
}

- (CGFloat)uu_right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setUu_right:(CGFloat)uu_right
{
    CGRect frame = self.frame;
    frame.origin.x = uu_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)uu_bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setUu_bottom:(CGFloat)uu_bottom
{
    CGRect frame = self.frame;
    frame.origin.y = uu_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)uu_width
{
    return self.frame.size.width;
}

- (void)setUu_width:(CGFloat)uu_width
{
    CGRect frame = self.frame;
    frame.size.width = uu_width;
    self.frame = frame;
}

- (CGFloat)uu_height
{
    return self.frame.size.height;
}

- (void)setUu_height:(CGFloat)uu_height
{
    CGRect frame = self.frame;
    frame.size.height = uu_height;
    self.frame = frame;
}

- (CGFloat)uu_centerX
{
    return self.center.x;
}

- (void)setUu_centerX:(CGFloat)uu_centerX
{
    CGPoint center = self.center;
    center.x = uu_centerX;
    self.center = center;
}

- (CGFloat)uu_centerY
{
    return self.center.y;
}

- (void)setUu_centerY:(CGFloat)uu_centerY
{
    CGPoint center = self.center;
    center.y = uu_centerY;
    self.center = center;
}

@end

@implementation UIScreen (UUChatCategory)

+ (CGFloat)uu_screenWidth
{
    return [self uu_screenSize].width;
}

+ (CGFloat)uu_screenHeight
{
    return [self uu_screenSize].height;
}

+ (CGSize)uu_screenSize
{
    return [self uu_screenBounds].size;
}

+ (CGRect)uu_screenBounds
{
    return UIScreen.mainScreen.bounds;
}

@end

@implementation UIImage (UUChatCategory)

+ (nullable instancetype)uu_imageWithName:(NSString *)imageName
{
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)uu_imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (nullable UIImage *)uu_symbolImageNamed:(NSString *)symbolName
                                 pointSize:(CGFloat)pointSize
                                    weight:(UIImageSymbolWeight)weight
                                 tintColor:(UIColor *)tintColor
{
#if __IPHONE_13_0
    UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:weight];
    UIImage *image = [UIImage systemImageNamed:symbolName withConfiguration:configuration];
    return [image imageWithTintColor:tintColor renderingMode:UIImageRenderingModeAlwaysOriginal];
#else
    return nil;
#endif
}

@end

@implementation NSString (UUChatCategory)

- (CGSize)uu_sizeWithFont:(UIFont *)font
{
    CGSize result = [self sizeWithAttributes:@{ NSFontAttributeName : font }];
    result.height = ceil(result.height);
    result.width = ceil(result.width);
    return result;
}

- (CGSize)uu_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGSize result = [self boundingRectWithSize:size
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:@{ NSFontAttributeName : font }
                                       context:nil].size;
    result.height = ceil(result.height);
    result.width = ceil(result.width);
    return result;
}

@end

@implementation UIResponder (UUChatCategory)

- (nullable __kindof UIResponder *)uu_findNextResponderInClass:(Class)responderClass
{
    UIResponder *next = self;
    do {
        next = next.nextResponder;
        if ([next isKindOfClass:responderClass]) {
            break;
        }
    } while (next != nil && ![next conformsToProtocol:@protocol(UIApplicationDelegate)]);

    return next;
}

- (nullable __kindof UIResponder *)uu_findNextResonderInClass:(Class)responderClass
{
    return [self uu_findNextResponderInClass:responderClass];
}

@end
