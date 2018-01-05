//
//  UUChatCategory.m
//  UUChatTableView
//
//  Created by XcodeYang on 04/01/2018.
//  Copyright © 2018 uyiuyao. All rights reserved.
//

#import "UUChatCategory.h"
#import "UUMessage.h"

@implementation UIView(UUChatCategory)

- (CGFloat)uu_left {
	return self.frame.origin.x;
}

- (void)setUu_left:(CGFloat)uu_left
{
	CGRect frame = self.frame;
	frame.origin.x = uu_left;
	self.frame = frame;
}

- (CGFloat)uu_top {
	return self.frame.origin.y;
}

- (void)setUu_top:(CGFloat)uu_top
{
	CGRect frame = self.frame;
	frame.origin.y = uu_top;
	self.frame = frame;
}

- (CGFloat)uu_right {
	return self.frame.origin.x + self.frame.size.width;
}

- (void)setUu_right:(CGFloat)uu_right
{
	CGRect frame = self.frame;
	frame.origin.x = uu_right - frame.size.width;
	self.frame = frame;
}

- (CGFloat)uu_bottom {
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setUu_bottom:(CGFloat)uu_bottom
{
	CGRect frame = self.frame;
	frame.origin.y = uu_bottom - frame.size.height;
	self.frame = frame;
}

- (CGFloat)uu_width {
	return self.frame.size.width;
}

- (void)setUu_width:(CGFloat)uu_width
{
	CGRect frame = self.frame;
	frame.size.width = uu_width;
	self.frame = frame;
}

- (CGFloat)uu_height {
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
	return [UIScreen mainScreen].bounds;
}

@end


@implementation UIDevice(UUChatCategory)

+ (BOOL)uu_isIPhone
{
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

+ (BOOL)uu_isIPhoneX
{
#ifdef __IPHONE_11_0
	return CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size);
#else
	return NO;
#endif
}

@end



@implementation UIImage(CKPhotoBrowserCategory)

+ (nullable instancetype)uu_imageWithName:(NSString *)imageName
{
	//NOTE: @"image/%@" 不要写成 @"/image/%@"
	NSString *bundleImageName = [NSString stringWithFormat:@"image/%@",imageName];
	UIImage *image = [UIImage imageNamed:bundleImageName inBundle:[NSBundle uu_photoViewerResourceBundle] compatibleWithTraitCollection:nil];
	image = image ?: [UIImage imageNamed:[NSString stringWithFormat:@"CKPhotoBrowser.bundle/image/%@",imageName]];
	return image ?: [UIImage imageNamed:imageName];
}

+ (UIImage *)uu_imageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

@end


@implementation NSBundle(CKPhotoBrowserCategory)

+ (nullable instancetype)uu_photoViewerResourceBundle
{
	NSString *resourceBundlePath = [[NSBundle bundleForClass:[UUMessage class]] pathForResource:@"UUChatTableView" ofType:@"bundle"];
	return [self bundleWithPath:resourceBundlePath];
}

@end



@implementation NSString(UUChatCategory)

- (CGSize)uu_sizeWithFont:(UIFont *)font
{
	CGSize result = [self sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
	result.height = ceilf(result.height);
	result.width = ceilf(result.width);
	return result;
}

- (CGSize)uu_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
	CGSize result = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil] context:nil].size;
	result.height = ceilf(result.height);
	result.width = ceilf(result.width);
	return result;
}

@end



@implementation UIResponder(UUChatCategory)

- (nullable __kindof UIResponder *)uu_findNextResonderInClass:(nonnull Class)responderClass
{
	UIResponder *next = self;
	do {
		next = [next nextResponder];
		if ([next isKindOfClass:responderClass]) {
			break;
		}
		// next 不为空 且 不是达到最底层的 appdelegate
	} while (next!=nil && ![next conformsToProtocol:@protocol(UIApplicationDelegate)]);
	
	return next;
}

@end
