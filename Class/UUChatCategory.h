//
//  UUChatCategory.h
//  UUChatTableView
//
//  Created by XcodeYang on 04/01/2018.
//  Copyright © 2018 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView(UUChatCategory)

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



@interface UIDevice(UUChatCategory)

+ (BOOL)uu_isIPhone;

+ (BOOL)uu_isIPhoneX;

@end



@interface UIImage (UUChatCategory)

/**
 *  本地 UIImage 获取
 */
+ (nullable instancetype)uu_imageWithName:(NSString *)imageName;

+ (UIImage *)uu_imageWithColor:(UIColor *)color;

@end


@interface NSBundle(UUChatCategory)
/**
 *  pod库本地bundle文件获取
 */
+ (nullable instancetype)uu_photoViewerResourceBundle;

@end

@interface NSString(UUChatCategory)

- (CGSize)uu_sizeWithFont:(UIFont *)font;

- (CGSize)uu_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

@end



@interface UIResponder(UUChatCategory)

- (nullable __kindof UIResponder *)uu_findNextResonderInClass:(nonnull Class)responderClass;

@end


NS_ASSUME_NONNULL_END
