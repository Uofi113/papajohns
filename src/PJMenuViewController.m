// PJMenuViewController.m
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import "PJMenuViewController.h"
#import "PJMenuCell.h"
#import "PJMenuItem.h"
#import "PJNetworkManager.h"

static NSString * const kCellID = @"PJMenuCell";

@interface PJMenuViewController ()
@property (nonatomic, strong) NSArray                 *items;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation PJMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Меню";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // текстура дерева через colorWithPatternImage:
    self.tableView.backgroundColor =
        [UIColor colorWithPatternImage:[self _woodTextureImage]];

    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center           = self.view.center;
    _spinner.hidesWhenStopped = YES;
    [self.view addSubview:_spinner];
    [_spinner startAnimating];

    [self _loadMenu];
}

// ── Загрузка меню ────────────────────────────────────────────────────────────
- (void)_loadMenu {
    [[PJNetworkManager sharedManager]
        GET:@"/menu"
        parameters:nil
        success:^(id responseObject) {
            [_spinner stopAnimating];
            NSArray *raw = responseObject[@"items"] ?: responseObject;
            NSMutableArray *parsed = [NSMutableArray array];
            for (NSDictionary *d in raw)
                [parsed addObject:[PJMenuItem itemFromDictionary:d]];
            _items = [parsed copy];
            [self.tableView reloadData];
        }
        failure:^(NSError *error) {
            [_spinner stopAnimating];
            [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                       message:error.localizedDescription
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil].show;
        }];
}

// ── UITableViewDataSource ────────────────────────────────────────────────────
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    return (NSInteger)_items.count;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)ip {
    return [PJMenuCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)ip
{
    PJMenuCell *cell = [tv dequeueReusableCellWithIdentifier:kCellID];
    if (!cell)
        cell = [[PJMenuCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:kCellID];

    PJMenuItem *item = _items[(NSUInteger)ip.row];
    [cell configureWithItem:item];

    __weak PJMenuViewController *weak = self;
    cell.addToCartBlock = ^(PJMenuItem *tapped) {
        [weak _addItemToCart:tapped];
    };
    return cell;
}

// ── Корзина ──────────────────────────────────────────────────────────────────
- (void)_addItemToCart:(PJMenuItem *)item {
    [[PJNetworkManager sharedManager]
        POST:@"/cart/add"
        parameters:@{ @"item_id": item.itemId, @"quantity": @1 }
        success:^(id resp) {
            NSString *old = self.title;
            self.title    = @"✓ Добавлено";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                           (int64_t)(1.2 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{ self.title = old; });
        }
        failure:^(NSError *err) {
            [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                       message:err.localizedDescription
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil].show;
        }];
}

// ── Текстура дерева (CGContext, zero-asset) ───────────────────────────────────
- (UIImage *)_woodTextureImage {
    CGSize sz = CGSizeMake(128.f, 128.f);
    UIGraphicsBeginImageContextWithOptions(sz, YES, 0.f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // базовый тёплый коричневый фон
    CGContextSetFillColorWithColor(ctx,
        [UIColor colorWithRed:0.42f green:0.28f blue:0.14f alpha:1.f].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, sz.width, sz.height));

    // прожилки
    srand48(42);
    for (NSInteger i = 0; i < 18; i++) {
        CGFloat y     = (sz.height / 18.f) * i + drand48() * 4.0 - 2.0;
        CGFloat lw    = 1.f + drand48() * 1.5f;
        CGFloat alpha = 0.12f + drand48() * 0.18f;
        CGContextSetFillColorWithColor(ctx,
            [UIColor colorWithRed:0.22f green:0.13f blue:0.05f alpha:alpha].CGColor);
        CGContextFillRect(ctx, CGRectMake(0, y, sz.width, lw));
    }

    // лаковый блик сверху
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CFArrayRef colors = (__bridge CFArrayRef)@[
        (id)[UIColor colorWithWhite:1.f alpha:0.10f].CGColor,
        (id)[UIColor colorWithWhite:1.f alpha:0.00f].CGColor
    ];
    CGGradientRef grad = CGGradientCreateWithColors(cs, colors, NULL);
    CGContextDrawLinearGradient(ctx, grad,
        CGPointZero, CGPointMake(0, sz.height * 0.4f), 0);
    CGGradientRelease(grad);
    CGColorSpaceRelease(cs);

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
