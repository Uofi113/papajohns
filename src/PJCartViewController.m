// PJCartViewController.m
// Папаша Беппе iOS 6 client
// (c) uofist | tg: @uofist

#import "PJCartViewController.h"
#import "PJCartManager.h"
#import "PJNetworkManager.h"
#import "PJGlossButton.h"
#import <QuartzCore/QuartzCore.h>

// ─────────────────────────────────────────────────────────────────────────────
// Приватная ячейка корзины (имя / цена / кнопки ±)
// ─────────────────────────────────────────────────────────────────────────────
@interface PJCartCell : UITableViewCell
@property (nonatomic, strong) UILabel  *nameLabel;
@property (nonatomic, strong) UILabel  *priceLabel;
@property (nonatomic, strong) UILabel  *qtyLabel;
@property (nonatomic, strong) UIButton *minusBtn;
@property (nonatomic, strong) UIButton *plusBtn;
@property (nonatomic, copy)   void (^onIncrement)(void);
@property (nonatomic, copy)   void (^onDecrement)(void);
- (void)configureWithCartItem:(PJCartItem *)ci;
@end

@implementation PJCartCell

- (instancetype)initWithStyle:(UITableViewCellStyle)s reuseIdentifier:(NSString *)r {
    self = [super initWithStyle:s reuseIdentifier:r];
    if (!self) return nil;

    self.selectionStyle  = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];

    // Название
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font      = [UIFont boldSystemFontOfSize:15.f];
    _nameLabel.textColor = [UIColor colorWithWhite:0.1f alpha:1.f];
    _nameLabel.numberOfLines = 2;
    [self.contentView addSubview:_nameLabel];

    // Цена (справа)
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.font          = [UIFont boldSystemFontOfSize:15.f];
    _priceLabel.textColor     = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    _priceLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_priceLabel];

    // Кнопка −
    _minusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _minusBtn.backgroundColor    = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    _minusBtn.layer.cornerRadius = 14.f;
    _minusBtn.titleLabel.font    = [UIFont boldSystemFontOfSize:20.f];
    [_minusBtn setTitle:@"−" forState:UIControlStateNormal];
    [_minusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_minusBtn addTarget:self action:@selector(_minus) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_minusBtn];

    // Количество
    _qtyLabel = [[UILabel alloc] init];
    _qtyLabel.font          = [UIFont boldSystemFontOfSize:18.f];
    _qtyLabel.textAlignment = NSTextAlignmentCenter;
    _qtyLabel.textColor     = [UIColor colorWithWhite:0.1f alpha:1.f];
    [self.contentView addSubview:_qtyLabel];

    // Кнопка +
    _plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _plusBtn.backgroundColor    = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    _plusBtn.layer.cornerRadius = 14.f;
    _plusBtn.titleLabel.font    = [UIFont boldSystemFontOfSize:20.f];
    [_plusBtn setTitle:@"+" forState:UIControlStateNormal];
    [_plusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_plusBtn addTarget:self action:@selector(_plus) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_plusBtn];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat W = self.contentView.bounds.size.width;
    CGFloat H = self.contentView.bounds.size.height;

    _nameLabel.frame  = CGRectMake(14.f, 8.f,  W - 115.f, H/2.f - 6.f);
    _priceLabel.frame = CGRectMake(W - 110.f, 8.f, 100.f, H/2.f - 6.f);

    CGFloat bSz = 28.f;
    CGFloat bY  = H/2.f + (H/2.f - bSz)/2.f;
    _minusBtn.frame = CGRectMake(14.f,           bY, bSz, bSz);
    _qtyLabel.frame = CGRectMake(14.f + bSz + 4.f, bY, 32.f, bSz);
    _plusBtn.frame  = CGRectMake(14.f + bSz + 40.f,bY, bSz, bSz);
}

- (void)configureWithCartItem:(PJCartItem *)ci {
    _nameLabel.text  = ci.menuItem.name;
    _priceLabel.text = [NSString stringWithFormat:@"%.0f руб.", ci.totalPrice];
    _qtyLabel.text   = [NSString stringWithFormat:@"%ld", (long)ci.quantity];
}

- (void)_minus { if (_onDecrement) _onDecrement(); }
- (void)_plus  { if (_onIncrement) _onIncrement(); }

@end

// ─────────────────────────────────────────────────────────────────────────────
// PJCartViewController
// ─────────────────────────────────────────────────────────────────────────────
static NSString * const kCartCellID = @"PJCartCell";

@interface PJCartViewController ()
@property (nonatomic, strong) NSArray  *cartItems;
@property (nonatomic, strong) UILabel  *totalLabel;
@end

@implementation PJCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Корзина";
    self.tableView.rowHeight        = 82.f;
    self.tableView.backgroundColor  =
        [UIColor colorWithRed:0.96f green:0.94f blue:0.91f alpha:1.f];
    self.tableView.separatorColor   = [UIColor colorWithWhite:0.85f alpha:1.f];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 14, 0, 14);
    }
    [self.tableView registerClass:[PJCartCell class] forCellReuseIdentifier:kCartCellID];

    // ── Footer: итого + кнопка заказа ────────────────────────────────────
    CGFloat fW = self.view.bounds.size.width;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, fW, 110.f)];
    footer.backgroundColor = [UIColor whiteColor];

    // тонкая линия сверху
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fW, 1)];
    sep.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.f];
    [footer addSubview:sep];

    _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.f, 10.f, fW - 32.f, 28.f)];
    _totalLabel.font      = [UIFont boldSystemFontOfSize:19.f];
    _totalLabel.textColor = [UIColor colorWithWhite:0.1f alpha:1.f];
    [footer addSubview:_totalLabel];

    PJGlossButton *orderBtn = [[PJGlossButton alloc]
        initWithFrame:CGRectMake(16.f, 46.f, fW - 32.f, 50.f)];
    [orderBtn setTitle:@"Оформить заказ" forState:UIControlStateNormal];
    orderBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    [orderBtn addTarget:self action:@selector(_placeOrder)
       forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:orderBtn];

    self.tableView.tableFooterView = footer;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_reload)
                                                 name:PJCartDidUpdateNotification
                                               object:nil];
    [self _reload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_reload {
    _cartItems = [PJCartManager sharedManager].cartItems;
    _totalLabel.text = [NSString stringWithFormat:@"Итого: %.0f руб.",
                        [PJCartManager sharedManager].totalPrice];
    [self.tableView reloadData];
}

// ── DataSource ────────────────────────────────────────────────────────────
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    return (NSInteger)_cartItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)ip
{
    PJCartCell *cell = (PJCartCell *)[tv dequeueReusableCellWithIdentifier:kCartCellID];
    if (!cell) {
        cell = [[PJCartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCartCellID];
    }
    PJCartItem *ci   = _cartItems[(NSUInteger)ip.row];
    [cell configureWithCartItem:ci];

    cell.onIncrement = ^{ [[PJCartManager sharedManager] incrementItem:ci.menuItem]; };
    cell.onDecrement = ^{ [[PJCartManager sharedManager] decrementItem:ci.menuItem]; };
    return cell;
}

// ── Оформить заказ ────────────────────────────────────────────────────────
- (void)_placeOrder {
    if ([PJCartManager sharedManager].totalCount == 0) return;

    // Build order summary
    NSMutableString *summary = [NSMutableString stringWithString:@"\u0412\u0430\u0448 \u0437\u0430\u043a\u0430\u0437:\n"];
    for (PJCartItem *ci in [PJCartManager sharedManager].cartItems) {
        [summary appendFormat:@"\u2022 %@ x%ld \u2014 %.0f \u0440\u0443\u0431.\n",
            ci.menuItem.name, (long)ci.quantity, ci.totalPrice];
    }
    [summary appendFormat:@"\n\u0418\u0442\u043e\u0433\u043e: %.0f \u0440\u0443\u0431.\n\n"
                           "\u041f\u043e\u0437\u0432\u043e\u043d\u0438\u0442\u044c: +7 (4012) 312-312",
        [PJCartManager sharedManager].totalPrice];

    UIAlertView *alert = [[UIAlertView alloc]
        initWithTitle:@"\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0434\u0438\u0442\u0435 \u0437\u0430\u043a\u0430\u0437"
              message:summary
             delegate:self
    cancelButtonTitle:@"\u041e\u0442\u043c\u0435\u043d\u0430"
    otherButtonTitles:@"\u0417\u0432\u043e\u043d\u0438\u0442\u044c!", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)idx {
    if (idx == 1) {
        NSURL *url = [NSURL URLWithString:@"tel:+74012312312"];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
