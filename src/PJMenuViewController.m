// PJMenuViewController.m
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import "PJMenuViewController.h"
#import "PJMenuCell.h"
#import "PJSberCell.h"
#import "PJMenuItem.h"
#import "PJNetworkManager.h"
#import "PJCartManager.h"
#import "PJItemDetailViewController.h"
#import "PJCartViewController.h"
#import "PJAuthViewController.h"

static NSString * const kMenuCellID = @"PJMenuCell";
static NSString * const kSberCellID = @"PJSberCell";

@interface PJMenuViewController ()
@property (nonatomic, strong) NSArray                 *items;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIBarButtonItem         *cartBtn;
@end

@implementation PJMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Меню";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor =
        [UIColor colorWithPatternImage:[self _woodTextureImage]];

    // Кнопка корзины
    _cartBtn = [[UIBarButtonItem alloc]
        initWithTitle:@"Корзина"
                style:UIBarButtonItemStyleBordered
               target:self
               action:@selector(_openCart)];
    self.navigationItem.rightBarButtonItem = _cartBtn;

    // Кнопка логаут
    UIBarButtonItem *logoutBtn = [[UIBarButtonItem alloc]
        initWithTitle:@"Выход"
                style:UIBarButtonItemStyleBordered
               target:self
               action:@selector(_logout)];
    self.navigationItem.leftBarButtonItem = logoutBtn;

    // Спиннер
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center           = self.view.center;
    _spinner.hidesWhenStopped = YES;
    [self.view addSubview:_spinner];
    [_spinner startAnimating];

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(_cartUpdated) name:PJCartDidUpdateNotification object:nil];

    [self _loadMenu];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_cartUpdated {
    NSInteger n = [PJCartManager sharedManager].totalCount;
    _cartBtn.title = n > 0
        ? [NSString stringWithFormat:@"Корзина (%ld)", (long)n]
        : @"Корзина";
}

- (void)_loadMenu {
    [[PJNetworkManager sharedManager]
        fetchMenuWithSuccess:^(id resp) {
            [_spinner stopAnimating];
            NSArray *raw = nil;
            if ([resp isKindOfClass:[NSArray class]]) {
                raw = resp;
            } else if ([resp isKindOfClass:[NSDictionary class]]) {
                raw = resp[@"items"] ?: resp[@"data"];
            }
            if (!raw || ![raw isKindOfClass:[NSArray class]]) {
                raw = @[];
            }
            NSMutableArray *parsed = [NSMutableArray array];
            for (NSDictionary *d in raw)
                [parsed addObject:[PJMenuItem itemFromDictionary:d]];
            _items = [parsed copy];
            [self.tableView reloadData];
        }
        failure:^(NSError *err) {
            [_spinner stopAnimating];
            UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Ошибка API"
                message:err.localizedDescription delegate:nil
                cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [a show];
        }];
}

// ── DataSource ────────────────────────────────────────────────────────────
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv { return 2; }

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    return s == 0 ? (NSInteger)_items.count : 1;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)ip {
    return ip.section == 1 ? [PJSberCell cellHeight] : [PJMenuCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)ip
{
    if (ip.section == 1) {
        PJSberCell *cell = [tv dequeueReusableCellWithIdentifier:kSberCellID];
        if (!cell) cell = [[PJSberCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:kSberCellID];
        return cell;
    }

    PJMenuCell *cell = [tv dequeueReusableCellWithIdentifier:kMenuCellID];
    if (!cell) cell = [[PJMenuCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:kMenuCellID];
    PJMenuItem *item = _items[(NSUInteger)ip.row];
    [cell configureWithItem:item];

    __weak PJMenuViewController *weak = self;
    cell.addToCartBlock = ^(PJMenuItem *tapped) {
        [[PJCartManager sharedManager] addItem:tapped];
        NSString *old = weak.title;
        weak.title = @"✓ Добавлено";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{ weak.title = old; });
    };
    return cell;
}

// ── Delegate ──────────────────────────────────────────────────────────────
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    [tv deselectRowAtIndexPath:ip animated:YES];
    if (ip.section == 1) return;  // SberSpasibo — нетапаемый
    PJMenuItem *item = _items[(NSUInteger)ip.row];
    PJItemDetailViewController *detail = [[PJItemDetailViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)_openCart {
    PJCartViewController *cart = [[PJCartViewController alloc]
        initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:cart animated:YES];
}

- (void)_logout {
    [PJNetworkManager sharedManager].authToken = nil;
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Успешно" message:@"Вы вышли из аккаунта" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [a show];
    
    // Возвращаемся на экран авторизации
    PJAuthViewController *auth = [[PJAuthViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:auth];
    [self.view.window setRootViewController:nc];
}

// ── Текстура дерева ───────────────────────────────────────────────────────
- (UIImage *)_woodTextureImage {
    CGSize sz = CGSizeMake(128.f, 128.f);
    UIGraphicsBeginImageContextWithOptions(sz, YES, 0.f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx,
        [UIColor colorWithRed:0.42f green:0.28f blue:0.14f alpha:1.f].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, sz.width, sz.height));
    srand48(42);
    for (NSInteger i = 0; i < 18; i++) {
        CGFloat y  = (sz.height / 18.f) * i + drand48() * 4.0 - 2.0;
        CGFloat lw = 1.f + drand48() * 1.5f;
        CGFloat a  = 0.12f + drand48() * 0.18f;
        CGContextSetFillColorWithColor(ctx,
            [UIColor colorWithRed:0.22f green:0.13f blue:0.05f alpha:a].CGColor);
        CGContextFillRect(ctx, CGRectMake(0, y, sz.width, lw));
    }
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gr = CGGradientCreateWithColors(cs, (__bridge CFArrayRef)@[
        (id)[UIColor colorWithWhite:1.f alpha:0.10f].CGColor,
        (id)[UIColor colorWithWhite:1.f alpha:0.00f].CGColor
    ], NULL);
    CGContextDrawLinearGradient(ctx, gr, CGPointZero, CGPointMake(0, sz.height * 0.4f), 0);
    CGGradientRelease(gr);
    CGColorSpaceRelease(cs);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
