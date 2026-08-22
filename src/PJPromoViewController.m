// PJPromoViewController.m
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PJPromoItem.h"
#import "PJNetworkManager.h"

// ── Promo Cell ───────────────────────────────────────────────────────────────

@interface PJPromoCell : UITableViewCell
@property (nonatomic, strong) UIImageView *promoImageView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *teaserLabel;
- (void)configureWithPromo:(PJPromoItem *)promo;
@end

@implementation PJPromoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor colorWithRed:0.97f green:0.95f blue:0.92f alpha:1.f];

    // Promo image
    _promoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.f, 10.f, 80.f, 60.f)];
    _promoImageView.contentMode   = UIViewContentModeScaleAspectFill;
    _promoImageView.clipsToBounds = YES;
    _promoImageView.layer.cornerRadius = 6.f;
    _promoImageView.layer.borderWidth  = 1.f;
    _promoImageView.layer.borderColor  = [UIColor colorWithWhite:0.8f alpha:1.f].CGColor;
    _promoImageView.backgroundColor    = [UIColor colorWithRed:0.90f green:0.85f blue:0.80f alpha:1.f];
    [self.contentView addSubview:_promoImageView];

    // Promo star/badge
    UILabel *badge = [[UILabel alloc] initWithFrame:CGRectMake(12.f, 10.f, 80.f, 20.f)];
    badge.text            = @"\u0410\u041a\u0426\u0418\u042f";
    badge.font            = [UIFont boldSystemFontOfSize:10.f];
    badge.textColor       = [UIColor whiteColor];
    badge.textAlignment   = NSTextAlignmentCenter;
    badge.backgroundColor = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:0.85f];
    [self.contentView addSubview:badge];

    // Title
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font          = [UIFont boldSystemFontOfSize:15.f];
    _titleLabel.textColor     = [UIColor colorWithWhite:0.1f alpha:1.f];
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];

    // Teaser
    _teaserLabel = [[UILabel alloc] init];
    _teaserLabel.font          = [UIFont systemFontOfSize:12.f];
    _teaserLabel.textColor     = [UIColor colorWithWhite:0.4f alpha:1.f];
    _teaserLabel.numberOfLines = 3;
    [self.contentView addSubview:_teaserLabel];

    // Bottom separator
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 79.f, 320.f, 1.f)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    line.backgroundColor  = [UIColor colorWithWhite:0.82f alpha:1.f];
    [self.contentView addSubview:line];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat W = self.contentView.bounds.size.width;
    CGFloat textX = 104.f;
    CGFloat textW = W - textX - 12.f;
    _titleLabel.frame  = CGRectMake(textX, 10.f, textW, 38.f);
    _teaserLabel.frame = CGRectMake(textX, 50.f, textW, 26.f);
}

- (void)configureWithPromo:(PJPromoItem *)promo {
    _titleLabel.text  = promo.title;
    _teaserLabel.text = promo.teaser.length ? promo.teaser : promo.itemDescription;
    _promoImageView.image = nil;

    if (promo.imageURL.length) {
        NSString *url = promo.imageURL;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *d = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            UIImage *img = d ? [UIImage imageWithData:d] : nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.2f animations:^{ self->_promoImageView.image = img; }];
            });
        });
    }
}

+ (CGFloat)cellHeight { return 80.f; }

@end

// ── PJPromoDetailViewController ──────────────────────────────────────────────

@interface PJPromoDetailViewController : UIViewController
- (instancetype)initWithPromo:(PJPromoItem *)promo;
@end

@implementation PJPromoDetailViewController {
    PJPromoItem *_promo;
    UIImageView *_imageView;
}

- (instancetype)initWithPromo:(PJPromoItem *)promo {
    self = [super init];
    if (self) _promo = promo;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"\u0410\u043a\u0446\u0438\u044f";
    self.view.backgroundColor = [UIColor colorWithRed:0.96f green:0.94f blue:0.91f alpha:1.f];

    CGFloat W = self.view.bounds.size.width;
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    sv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:sv];

    CGFloat y = 0.f;

    // Image
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, W, 200.f)];
    _imageView.contentMode    = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds  = YES;
    _imageView.backgroundColor = [UIColor colorWithRed:0.90f green:0.85f blue:0.80f alpha:1.f];
    [sv addSubview:_imageView];
    y += 200.f;

    // АКЦИЯ badge
    UILabel *badge = [[UILabel alloc] initWithFrame:CGRectMake(14.f, y + 12.f, 70.f, 24.f)];
    badge.text          = @"\u0410\u041a\u0426\u0418\u042f";
    badge.font          = [UIFont boldSystemFontOfSize:11.f];
    badge.textColor     = [UIColor whiteColor];
    badge.textAlignment = NSTextAlignmentCenter;
    badge.backgroundColor = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    badge.layer.cornerRadius = 4.f;
    badge.clipsToBounds = YES;
    [sv addSubview:badge];
    y += 44.f;

    // Title
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text          = _promo.title;
    titleLbl.font          = [UIFont boldSystemFontOfSize:20.f];
    titleLbl.textColor     = [UIColor colorWithWhite:0.1f alpha:1.f];
    titleLbl.numberOfLines = 0;
    titleLbl.frame         = CGRectMake(14.f, y, W - 28.f, 200.f);
    [titleLbl sizeToFit];
    titleLbl.frame         = CGRectMake(14.f, y, W - 28.f, titleLbl.frame.size.height);
    [sv addSubview:titleLbl];
    y += titleLbl.frame.size.height + 12.f;

    // Separator
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(14.f, y, W - 28.f, 1.f)];
    sep.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.f];
    [sv addSubview:sep];
    y += 14.f;

    // Description
    NSString *descText = _promo.itemDescription.length ? _promo.itemDescription : _promo.teaser;
    UILabel *descLbl = [[UILabel alloc] init];
    descLbl.text          = descText;
    descLbl.font          = [UIFont systemFontOfSize:14.f];
    descLbl.textColor     = [UIColor colorWithWhite:0.35f alpha:1.f];
    descLbl.numberOfLines = 0;
    descLbl.frame         = CGRectMake(14.f, y, W - 28.f, 2000.f);
    [descLbl sizeToFit];
    descLbl.frame         = CGRectMake(14.f, y, W - 28.f, descLbl.frame.size.height);
    [sv addSubview:descLbl];
    y += descLbl.frame.size.height + 28.f;

    // "Вернуться в меню" info label
    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(14.f, y, W - 28.f, 40.f)];
    hint.text          = @"\u0427\u0442\u043e\u0431\u044b \u0441\u0434\u0435\u043b\u0430\u0442\u044c \u0437\u0430\u043a\u0430\u0437, \u043f\u0435\u0440\u0435\u0439\u0434\u0438\u0442\u0435 \u0432 \u0440\u0430\u0437\u0434\u0435\u043b \u00ab\u041c\u0435\u043d\u044e\u00bb \u2192";
    hint.font          = [UIFont italicSystemFontOfSize:13.f];
    hint.textColor     = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    hint.textAlignment = NSTextAlignmentCenter;
    [sv addSubview:hint];
    y += 50.f;

    sv.contentSize = CGSizeMake(W, y);

    // Load image
    if (_promo.imageURL.length) {
        NSString *url = _promo.imageURL;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *d = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            UIImage *img = d ? [UIImage imageWithData:d] : nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_imageView.image = img;
            });
        });
    }
}
@end

// ── PJPromoViewController ────────────────────────────────────────────────────

#import "PJPromoViewController.h"

@implementation PJPromoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.96f green:0.94f blue:0.91f alpha:1.f];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    _promos = @[];
}

- (void)reloadWithPromos:(NSArray *)promos {
    _promos = promos ?: @[];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    return (NSInteger)_promos.count;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)ip {
    return [PJPromoCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    static NSString *kID = @"PJPromoCell";
    PJPromoCell *cell = [tv dequeueReusableCellWithIdentifier:kID];
    if (!cell) cell = [[PJPromoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kID];
    [cell configureWithPromo:_promos[(NSUInteger)ip.row]];
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    [tv deselectRowAtIndexPath:ip animated:YES];
    PJPromoItem *promo = _promos[(NSUInteger)ip.row];
    PJPromoDetailViewController *detail = [[PJPromoDetailViewController alloc] initWithPromo:promo];
    [self.navigationController pushViewController:detail animated:YES];
}

@end