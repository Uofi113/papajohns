// AppDelegate.m
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import "AppDelegate.h"
#import "PJMenuViewController.h"
#import "PJNetworkManager.h"
#import "PJAuthViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor blackColor];

    PJMenuViewController *menu = [[PJMenuViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:menu];
    // Красный nav bar Papa John's
    nav.navigationBar.tintColor = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];

    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];

    // Проверяем авторизацию: если токена нет — показываем экран входа
    if (![PJNetworkManager sharedManager].authToken) {
        PJAuthViewController *auth = [[PJAuthViewController alloc] init];
        auth.modalPresentationStyle = UIModalPresentationFullScreen;
        __weak UINavigationController *weakNav = nav;
        auth.onAuthSuccess = ^{
            [weakNav dismissViewControllerAnimated:YES completion:nil];
        };
        // presentViewController нужно вызывать после того, как window стал key
        dispatch_async(dispatch_get_main_queue(), ^{
            [nav presentViewController:auth animated:NO completion:nil];
        });
    }

    return YES;
}

@end
