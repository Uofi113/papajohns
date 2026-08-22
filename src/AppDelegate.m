#import "AppDelegate.h"
#import "PJMenuViewController.h"
#import "PJPromoViewController.h"
#import "PJNetworkManager.h"
#import "PJPromoItem.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    PJMenuViewController *menu = [[PJMenuViewController alloc] init];
    UINavigationController *menuNC = [[UINavigationController alloc] initWithRootViewController:menu];
    menuNC.navigationBar.tintColor = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    
    self.window.rootViewController = menuNC;
    [self.window makeKeyAndVisible];

    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

@end
