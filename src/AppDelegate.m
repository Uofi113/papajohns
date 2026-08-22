#import "AppDelegate.h"
#import "PJMenuViewController.h"
#import "PJPromoViewController.h"
#import "PJNetworkManager.h"
#import "PJPromoItem.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    // --- Menu tab ---
    PJMenuViewController *menu = [[PJMenuViewController alloc] init];
    UINavigationController *menuNC = [[UINavigationController alloc] initWithRootViewController:menu];
    menuNC.navigationBar.tintColor = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    menuNC.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"Меню" image:nil tag:0];

    // --- Promos tab ---
    PJPromoViewController *promos = [[PJPromoViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *promosNC = [[UINavigationController alloc] initWithRootViewController:promos];
    promosNC.navigationBar.tintColor = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    promosNC.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"Акции" image:nil tag:1];
    promos.navigationItem.title = @"Акции";

    // --- Tab Bar ---
    UITabBarController *tabs = [[UITabBarController alloc] init];
    tabs.viewControllers = @[menuNC, promosNC];
    tabs.tabBar.tintColor    = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    tabs.tabBar.barTintColor = [UIColor colorWithRed:0.15f green:0.12f blue:0.10f alpha:1.f];

    self.window.rootViewController = tabs;
    [self.window makeKeyAndVisible];

    // Load promos after launch
    [[PJNetworkManager sharedManager]
        fetchMenuWithSuccess:^(id resp) {
            if (![resp isKindOfClass:[NSDictionary class]]) return;
            NSArray *rawPromos = resp[@"promotions"];
            if (![rawPromos isKindOfClass:[NSArray class]]) return;
            NSMutableArray *items = [NSMutableArray array];
            for (NSDictionary *d in rawPromos)
                [items addObject:[PJPromoItem itemFromDictionary:d]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [promos reloadWithPromos:items];
            });
        }
        failure:nil];

    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

@end
