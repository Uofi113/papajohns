// PJItemDetailViewController.m
// Папаша Беппе iOS 6 client
// (c) uofist | tg: @uofist

#import "PJItemDetailViewController.h"
#import "PJCartManager.h"
#import "PJCartViewController.h"
#import "PJGlossButton.h"
#import <QuartzCore/QuartzCore.h>

@interface PJItemDetailViewController ()
@property (nonatomic, strong) PJMenuItem  *item;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation PJItemDetailViewController

- (instancetype)initWithItem:(PJMenuItem *)item {
    self = [super init];
    if (self) _item = item;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _item.name;
    self.view.backgroundColor = [UIColor colorWithRed:0.96f green:0.94f blue:0.91f alpha:1.f];

    CGFloat W = self.view.bounds.size.width;

    // ── ScrollView ────────────────────────────────────────────────────────
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    sv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:sv];

    CGFloat y = 0.f;

    // ── Фото ─────────────────────────────────────────────────────────────
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, y, W, 220.f)];
    _imageView.contentMode    = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds  = YES;
    _imageView.backgroundColor = [UIColor colorWithRed:0.90f green:0.85f blue:0.80f alpha:1.f];
    [sv addSubview:_imageView];
    // градиент-переход внизу фото
    CAGradientLayer *fadeGrad = [CAGradientLayer layer];
    fadeGrad.frame  = CGRectMake(0.f, 140.f, W, 80.f);
    fadeGrad.colors = @[
        (id)[UIColor colorWithWhite:0.f alpha:0.f].CGColor,
        (id)[UIColor colorWithRed:0.96f green:0.94f blue:0.91f alpha:1.f].CGColor
    ];
    [_imageView.layer addSublayer:fadeGrad];
    y += 220.f;

    // ── Название ─────────────────────────────────────────────────────────
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(16.f, y + 14.f, W - 32.f, 56.f)];
    name.text          = _item.name;
    name.font          = [UIFont boldSystemFontOfSize:22.f];
    name.textColor     = [UIColor colorWithWhite:0.1f alpha:1.f];
    name.numberOfLines = 2;
    [sv addSubview:name];
    y += 76.f;

    // ── Цена ─────────────────────────────────────────────────────────────
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(16.f, y, W - 32.f, 36.f)];
    price.text      = [NSString stringWithFormat:@"%.0f руб.", _item.price];
    price.font      = [UIFont boldSystemFontOfSize:28.f];
    price.textColor = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    [sv addSubview:price];
    y += 48.f;

    // ── Разделитель ───────────────────────────────────────────────────────
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16.f, y, W - 32.f, 1.f)];
    line.backgroundColor = [UIColor colorWithWhite:0.80f alpha:1.f];
    [sv addSubview:line];
    y += 14.f;

    // ── Описание ─────────────────────────────────────────────────────────
    UILabel *desc = [[UILabel alloc] init];
    desc.text          = _item.itemDescription.length
                            ? _item.itemDescription
                            : @"Описание появится позже.";
    desc.font          = [UIFont systemFontOfSize:14.f];
    desc.textColor     = [UIColor colorWithWhite:0.45f alpha:1.f];
    desc.numberOfLines = 0;
    desc.frame         = CGRectMake(16.f, y, W - 32.f, 2000.f);
    [desc sizeToFit];
    desc.frame         = CGRectMake(16.f, y, W - 32.f, desc.frame.size.height);
    [sv addSubview:desc];
    y += desc.frame.size.height + 28.f;

    // ── Кнопка "В корзину" ────────────────────────────────────────────────
    CGFloat bW = MIN(W - 40.f, 280.f);
    PJGlossButton *btn = [[PJGlossButton alloc]
        initWithFrame:CGRectMake((W - bW)/2.f, y, bW, 52.f)];
    [btn setTitle:@"В корзину" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    [btn addTarget:self action:@selector(_addToCart) forControlEvents:UIControlEventTouchUpInside];
    [sv addSubview:btn];
    y += 72.f;

    sv.contentSize = CGSizeMake(W, y);

    // ── Асинхронная загрузка фото ─────────────────────────────────────────
    if (_item.imageURL.length) {
        NSString *url = _item.imageURL;
        if ([url hasPrefix:@"local://"]) {
            NSString *name = [url substringFromIndex:8];
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
            _imageView.image = [UIImage imageWithContentsOfFile:path];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData  *d = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                UIImage *img = d ? [UIImage imageWithData:d] : nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.3f animations:^{ _imageView.image = img; }];
                });
            });
        }
    }

    // ── Кнопка корзины в nav bar ──────────────────────────────────────────
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_updateCartBtn)
                                                 name:PJCartDidUpdateNotification
                                               object:nil];
    [self _updateCartBtn];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_updateCartBtn {
    NSInteger n = [PJCartManager sharedManager].totalCount;
    NSString *t = n > 0 ? [NSString stringWithFormat:@"Корзина (%ld)", (long)n] : @"Корзина";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:t style:UIBarButtonItemStyleBordered
               target:self action:@selector(_openCart)];
}

- (void)_addToCart {
    [[PJCartManager sharedManager] addItem:_item];
    // визуальный фидбэк: лёгкая вибрация кнопки
    [UIView animateWithDuration:0.08f animations:^{
        self.view.transform = CGAffineTransformMakeScale(0.97f, 0.97f);
    } completion:^(BOOL d) {
        [UIView animateWithDuration:0.08f animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)_openCart {
    PJCartViewController *cart = [[PJCartViewController alloc]
        initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:cart animated:YES];
}

@end
