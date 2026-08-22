// AppDelegate.m
// Папаша Беппе iOS 6 client
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
    // РљСЂР°СЃРЅС‹Р№ nav bar Papa John's
    nav.navigationBar.tintColor = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];

    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];

    // РџСЂРѕРІРµСЂСЏРµРј Р°РІС‚РѕСЂРёР·Р°С†РёСЋ: РµСЃР»Рё С‚РѕРєРµРЅР° РЅРµС‚ вЂ” РїРѕРєР°Р·С‹РІР°РµРј СЌРєСЂР°РЅ РІС…РѕРґР°
    if (![PJNetworkManager sharedManager].authToken) {
        PJAuthViewController *auth = [[PJAuthViewController alloc] init];
        auth.modalPresentationStyle = UIModalPresentationFullScreen;
        __weak UINavigationController *weakNav = nav;
        auth.onAuthSuccess = ^{
            [weakNav dismissViewControllerAnimated:YES completion:nil];
        };
        // presentViewController РЅСѓР¶РЅРѕ РІС‹Р·С‹РІР°С‚СЊ РїРѕСЃР»Рµ С‚РѕРіРѕ, РєР°Рє window СЃС‚Р°Р» key
        dispatch_async(dispatch_get_main_queue(), ^{
            [nav presentViewController:auth animated:NO completion:nil];
        });
    }

    return YES;
}

@end

