// PJMenuViewController.m
// Папаша Беппе iOS 6 client
// (c) uofist | tg: @uofist

#import "PJMenuViewController.h"
#import "PJItemDetailViewController.h"
#import "PJCartViewController.h"
#import "PJCartManager.h"
#import "PJNetworkManager.h"
#import "PJMenuCell.h"
#import "PJSberCell.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const kMenuCellID = @"PJMenuCell";
static NSString * const kSberCellID = @"PJSberCell";

@interface PJMenuViewController ()
@property (nonatomic, strong) NSArray                 *categories;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIBarButtonItem         *cartBtn;
@end

@implementation PJMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"\u041f\u0430\u043f\u0430\u0448\u0430 \u0411\u0435\u043f\u043f\u0435";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor =
        [UIColor colorWithPatternImage:[self _woodTextureImage]];

    _cartBtn = [[UIBarButtonItem alloc]
        initWithTitle:@"\u041a\u043e\u0440\u0437\u0438\u043d\u0430"
                style:UIBarButtonItemStyleBordered
               target:self
               action:@selector(_openCart)];
    self.navigationItem.rightBarButtonItem = _cartBtn;
    self.navigationItem.leftBarButtonItem = nil;

    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center           = self.view.center;
    _spinner.hidesWhenStopped = YES;
    [self.view addSubview:_spinner];
    [_spinner startAnimating];

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(_cartUpdated) name:PJCartDidUpdateNotification object:nil];

    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    [rc addTarget:self action:@selector(_loadMenu) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;

    [self _loadMenu];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_cartUpdated {
    NSInteger n = [PJCartManager sharedManager].totalCount;
    _cartBtn.title = n > 0
        ? [NSString stringWithFormat:@"\u041a\u043e\u0440\u0437\u0438\u043d\u0430 (%ld)", (long)n]
        : @"\u041a\u043e\u0440\u0437\u0438\u043d\u0430";
}

- (void)_loadMenu {
    [[PJNetworkManager sharedManager]
        fetchMenuWithSuccess:^(id resp) {
            [_spinner stopAnimating];
            if (self.refreshControl.isRefreshing) [self.refreshControl endRefreshing];

            NSArray *rawCats = nil;
            if ([resp isKindOfClass:[NSDictionary class]]) {
                rawCats = resp[@"categories"];
            }
            NSMutableArray *cats = [NSMutableArray array];
            if ([rawCats isKindOfClass:[NSArray class]]) {
                for (NSDictionary *cat in rawCats) {
                    NSArray *rawItems = cat[@"items"];
                    if (![rawItems isKindOfClass:[NSArray class]]) continue;
                    NSMutableArray *items = [NSMutableArray array];
                    for (NSDictionary *d in rawItems)
                        [items addObject:[PJMenuItem itemFromDictionary:d]];
                    if (items.count == 0) continue;
                    [cats addObject:@{@"title": cat[@"title"] ?: @"\u041c\u0435\u043d\u044e", @"items": items}];
                }
            } else {
                // fallback old format
                NSArray *rawItems = [resp isKindOfClass:[NSDictionary class]] ? resp[@"items"] : resp;
                if ([rawItems isKindOfClass:[NSArray class]]) {
                    NSMutableArray *items = [NSMutableArray array];
                    for (NSDictionary *d in rawItems) [items addObject:[PJMenuItem itemFromDictionary:d]];
                    [cats addObject:@{@"title": @"\u041c\u0435\u043d\u044e", @"items": items}];
                }
            }
            _categories = [cats copy];
            [self.tableView reloadData];
        }
        failure:^(NSError *err) {
            [_spinner stopAnimating];
            if (self.refreshControl.isRefreshing) [self.refreshControl endRefreshing];
            UIAlertView *a = [[UIAlertView alloc]
                initWithTitle:@"\u041d\u0435\u0442 \u0441\u043e\u0435\u0434\u0438\u043d\u0435\u043d\u0438\u044f"
                      message:@"\u041f\u043e\u0442\u044f\u043d\u0438\u0442\u0435 \u0432\u043d\u0438\u0437 \u0434\u043b\u044f \u043f\u043e\u0432\u0442\u043e\u0440\u0430."
                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [a show];
        }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    return (NSInteger)_categories.count + 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    if (s == (NSInteger)_categories.count) return 1;
    return (NSInteger)((NSArray *)_categories[(NSUInteger)s][@"items"]).count;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)ip {
    if (ip.section == (NSInteger)_categories.count) return [PJSberCell cellHeight];
    return [PJMenuCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tv heightForHeaderInSection:(NSInteger)s {
    if (s == (NSInteger)_categories.count) return 0;
    return 36.f;
}

- (UIView *)tableView:(UITableView *)tv viewForHeaderInSection:(NSInteger)s {
    if (s == (NSInteger)_categories.count) return nil;
    CGFloat W = tv.bounds.size.width;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, 36.f)];
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = header.bounds;
    grad.colors = @[
        (id)[UIColor colorWithRed:0.55f green:0.05f blue:0.05f alpha:1.f].CGColor,
        (id)[UIColor colorWithRed:0.78f green:0.10f blue:0.10f alpha:1.f].CGColor
    ];
    [header.layer addSublayer:grad];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 35.f, W, 1.f)];
    line.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3f];
    [header addSubview:line];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(14.f, 0, W - 28.f, 36.f)];
    lbl.text         = _categories[(NSUInteger)s][@"title"];
    lbl.font         = [UIFont boldSystemFontOfSize:14.f];
    lbl.textColor    = [UIColor whiteColor];
    lbl.shadowColor  = [UIColor colorWithWhite:0.f alpha:0.5f];
    lbl.shadowOffset = CGSizeMake(0, -1);
    lbl.backgroundColor = [UIColor clearColor];
    [header addSubview:lbl];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    if (ip.section == (NSInteger)_categories.count) {
        PJSberCell *cell = [tv dequeueReusableCellWithIdentifier:kSberCellID];
        if (!cell) cell = [[PJSberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSberCellID];
        return cell;
    }
    PJMenuCell *cell = [tv dequeueReusableCellWithIdentifier:kMenuCellID];
    if (!cell) cell = [[PJMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMenuCellID];
    NSArray *items = _categories[(NSUInteger)ip.section][@"items"];
    PJMenuItem *item = items[(NSUInteger)ip.row];
    [cell configureWithItem:item];
    __weak PJMenuViewController *weak = self;
    cell.addToCartBlock = ^(PJMenuItem *tapped) {
        [[PJCartManager sharedManager] addItem:tapped];
        NSString *old = weak.title;
        weak.title = @"\u0412 \u043a\u043e\u0440\u0437\u0438\u043d\u0443!";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{ weak.title = old; });
    };
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    [tv deselectRowAtIndexPath:ip animated:YES];
    if (ip.section == (NSInteger)_categories.count) return;
    NSArray *items = _categories[(NSUInteger)ip.section][@"items"];
    PJMenuItem *item = items[(NSUInteger)ip.row];
    PJItemDetailViewController *detail = [[PJItemDetailViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)_openCart {
    PJCartViewController *cart = [[PJCartViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:cart animated:YES];
}

- (UIImage *)_woodTextureImage {
    // Kitchen checkerboard tile pattern
    CGFloat tileSize = 32.f;
    CGSize sz = CGSizeMake(tileSize * 2, tileSize * 2);
    UIGraphicsBeginImageContextWithOptions(sz, YES, 0.f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // Tile colors: classic Italian kitchen - off-white and warm dark gray
    UIColor *light = [UIColor colorWithRed:0.94f green:0.92f blue:0.88f alpha:1.f];
    UIColor *dark  = [UIColor colorWithRed:0.28f green:0.26f blue:0.24f alpha:1.f];

    // Draw 2x2 checkerboard tile (tileable pattern)
    NSArray *colors = @[light, dark, dark, light];
    NSInteger idx2 = 0;
    for (NSInteger row = 0; row < 2; row++) {
        for (NSInteger col = 0; col < 2; col++) {
            CGContextSetFillColorWithColor(ctx, ((UIColor *)colors[idx2]).CGColor);
            CGContextFillRect(ctx, CGRectMake(col * tileSize, row * tileSize, tileSize, tileSize));
            idx2++;
        }
    }

    // Grout lines - thin dark lines between tiles
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.15f alpha:0.6f].CGColor);
    CGContextSetLineWidth(ctx, 1.5f);
    // Vertical grout
    CGContextMoveToPoint(ctx, tileSize, 0);
    CGContextAddLineToPoint(ctx, tileSize, sz.height);
    // Horizontal grout
    CGContextMoveToPoint(ctx, 0, tileSize);
    CGContextAddLineToPoint(ctx, sz.width, tileSize);
    CGContextStrokePath(ctx);

    // Subtle gloss highlight on each tile
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gr = CGGradientCreateWithColors(cs, (__bridge CFArrayRef)@[
        (id)[UIColor colorWithWhite:1.f alpha:0.12f].CGColor,
        (id)[UIColor colorWithWhite:1.f alpha:0.00f].CGColor
    ], NULL);
    CGContextDrawLinearGradient(ctx, gr, CGPointZero, CGPointMake(0, sz.height * 0.5f), 0);
    CGGradientRelease(gr);
    CGColorSpaceRelease(cs);

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
