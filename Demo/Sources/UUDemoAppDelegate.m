#import "UUDemoAppDelegate.h"
#import "UUDemoChatViewController.h"

@implementation UUDemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    UUDemoChatViewController *chatViewController = [[UUDemoChatViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
    navigationController.navigationBar.prefersLargeTitles = NO;
    self.window.rootViewController = navigationController;

    [self.window makeKeyAndVisible];
    return YES;
}

@end
