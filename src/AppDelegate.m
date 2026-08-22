#import "AppDelegate.h"
#import "PJMenuViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    PJMenuViewController *menu = [[PJMenuViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:menu];
    nc.navigationBar.tintColor = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    self.window.rootViewController = nc;

    [self.window makeKeyAndVisible];
    return YES;
}
@end
