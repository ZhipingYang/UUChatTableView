#import "UUImageAvatarBrowser.h"

static UIImageView *_uuOrginImageView;

@implementation UUImageAvatarBrowser

+ (void)showImage:(UIImageView *)avatarImageView
{
    UIImage *image = avatarImageView.image;
    if (!image) {
        return;
    }

    UIWindow *window = [self activeWindow];
    if (!window) {
        return;
    }

    _uuOrginImageView = avatarImageView;
    _uuOrginImageView.alpha = 0;

    UIView *backgroundView = [[UIView alloc] initWithFrame:window.bounds];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[avatarImageView convertRect:avatarImageView.bounds toView:window]];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tag = 1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer:tap];

    CGFloat screenWidth = CGRectGetWidth(window.bounds);
    CGFloat screenHeight = CGRectGetHeight(window.bounds);
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat scale = MIN(screenWidth / image.size.width, screenHeight / image.size.height);
        imageView.frame = CGRectMake(0, (screenHeight - image.size.height * scale) / 2.0, screenWidth, image.size.height * scale);
        backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    }];
}

+ (void)hideImage:(UITapGestureRecognizer *)tap
{
    UIView *backgroundView = tap.view;
    UIImageView *imageView = [backgroundView viewWithTag:1];

    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = [_uuOrginImageView convertRect:_uuOrginImageView.bounds toView:[self activeWindow]];
        backgroundView.backgroundColor = UIColor.clearColor;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
        _uuOrginImageView.alpha = 1;
    }];
}

+ (UIWindow *)activeWindow
{
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            continue;
        }
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        for (UIWindow *window in windowScene.windows) {
            if (window.isKeyWindow) {
                return window;
            }
        }
    }

    UIScene *firstScene = UIApplication.sharedApplication.connectedScenes.allObjects.firstObject;
    if ([firstScene isKindOfClass:[UIWindowScene class]]) {
        return ((UIWindowScene *)firstScene).windows.firstObject;
    }
    return nil;
}

@end
