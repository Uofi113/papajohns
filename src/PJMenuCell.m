// PJMenuCell.m
// Папаша Беппе iOS 6 client
// (c) uofist | tg: @uofist

#import "PJMenuCell.h"

static const CGFloat kCellHeight = 110.f;
static const CGFloat kCardInset  = 10.f;
static const CGFloat kCardRadius = 8.f;
static const CGFloat kThumbSize  = 80.f;

@interface PJMenuCell ()
@property (nonatomic, strong) UIView        *card;
@property (nonatomic, strong) UIImageView   *thumb;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *descLabel;
@property (nonatomic, strong) UILabel       *priceLabel;
@property (nonatomic, strong) PJGlossButton *cartButton;
@property (nonatomic, strong) PJMenuItem    *currentItem;
@end

@implementation PJMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.selectionStyle              = UITableViewCellSelectionStyleNone;
    self.backgroundColor             = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

    // ── белая карточка ────────────────────────────────────────────────────
    _card = [[UIView alloc] init];
    _card.backgroundColor    = [UIColor whiteColor];
    _card.layer.cornerRadius = kCardRadius;
    _card.clipsToBounds      = NO;
    _card.layer.shadowColor   = [UIColor blackColor].CGColor;
    _card.layer.shadowOpacity = 0.28f;
    _card.layer.shadowRadius  = 4.f;
    _card.layer.shadowOffset  = CGSizeMake(0.f, 2.f);
    [self.contentView addSubview:_card];

    // ── миниатюра ─────────────────────────────────────────────────────────
    _thumb = [[UIImageView alloc] init];
    _thumb.backgroundColor    = [UIColor colorWithWhite:0.92f alpha:1.f];
    _thumb.layer.cornerRadius = 6.f;
    _thumb.clipsToBounds      = YES;
    _thumb.contentMode        = UIViewContentModeScaleAspectFill;
    [_card addSubview:_thumb];

    // ── название ─────────────────────────────────────────────────────────
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font          = [UIFont boldSystemFontOfSize:15.f];
    _nameLabel.textColor     = [UIColor colorWithWhite:0.1f alpha:1.f];
    _nameLabel.numberOfLines = 1;
    [_card addSubview:_nameLabel];

    // ── описание ─────────────────────────────────────────────────────────
    _descLabel = [[UILabel alloc] init];
    _descLabel.font          = [UIFont systemFontOfSize:11.f];
    _descLabel.textColor     = [UIColor colorWithWhite:0.45f alpha:1.f];
    _descLabel.numberOfLines = 2;
    [_card addSubview:_descLabel];

    // ── цена ──────────────────────────────────────────────────────────────
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.font      = [UIFont boldSystemFontOfSize:16.f];
    _priceLabel.textColor = [UIColor colorWithRed:0.78f green:0.05f blue:0.08f alpha:1.f];
    [_card addSubview:_priceLabel];

    // ── кнопка ───────────────────────────────────────────────────────────
    _cartButton = [[PJGlossButton alloc] init];
    [_cartButton addTarget:self action:@selector(_cartTapped)
          forControlEvents:UIControlEventTouchUpInside];
    [_card addSubview:_cartButton];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat w  = self.contentView.bounds.size.width;
    CGFloat h  = self.contentView.bounds.size.height;

    CGRect cardFrame = CGRectMake(kCardInset, kCardInset * 0.5f,
                                  w - kCardInset * 2.f,
                                  h - kCardInset);
    _card.frame = cardFrame;

    // shadowPath — ключ к плавному скроллу
    UIBezierPath *sp = [UIBezierPath bezierPathWithRoundedRect:_card.bounds
                                                  cornerRadius:kCardRadius];
    _card.layer.shadowPath = sp.CGPath;

    CGFloat pad  = 10.f;
    _thumb.frame = CGRectMake(pad,
                              floorf((CGRectGetHeight(cardFrame) - kThumbSize) * 0.5f),
                              kThumbSize, kThumbSize);

    CGFloat textX = _thumb.hidden ? pad : CGRectGetMaxX(_thumb.frame) + pad;
    CGFloat textW = CGRectGetWidth(cardFrame) - textX - pad;

    _nameLabel.frame  = CGRectMake(textX, 10.f, textW, 20.f);
    
    // To avoid overlapping the button, we constrain the width of the descLabel.
    CGFloat descW = _cartButton.hidden ? textW : textW - btnW - 4.f;
    _descLabel.frame  = CGRectMake(textX, 33.f, descW, 40.f);
    _priceLabel.frame = CGRectMake(textX, 74.f, 120.f, 22.f);

    CGFloat btnW = 90.f, btnH = 30.f;
    _cartButton.frame = CGRectMake(CGRectGetWidth(cardFrame) - btnW - pad,
                                   CGRectGetHeight(cardFrame) - btnH - pad,
                                   btnW, btnH);
}

- (void)configureWithItem:(PJMenuItem *)item {
    _currentItem     = item;
    _nameLabel.text  = item.name;
    _descLabel.text  = item.itemDescription;
    if (item.price <= 0.01f) {
        _priceLabel.hidden = YES;
        _cartButton.hidden = YES;
    } else {
        _priceLabel.hidden = NO;
        _cartButton.hidden = NO;
        _priceLabel.text = [NSString stringWithFormat:@"%.0f \u0440\u0443\u0431.", item.price];
    }

    _thumb.image = nil;
    _thumb.hidden = (item.imageURL.length == 0);
    if (item.imageURL.length > 0) {
        if ([item.imageURL hasPrefix:@"local://"]) {
            NSString *filename = [item.imageURL substringFromIndex:8];
            _thumb.image = [UIImage imageNamed:filename];
        } else {
            NSString *urlCopy = [item.imageURL copy];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlCopy]];
                UIImage *img  = data ? [UIImage imageWithData:data] : nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_currentItem.imageURL isEqualToString:urlCopy])
                        _thumb.image = img;
                });
            });
        }
    }
    [self setNeedsLayout];
}

+ (CGFloat)cellHeight { return kCellHeight; }

- (void)_cartTapped {
    if (_addToCartBlock) _addToCartBlock(_currentItem);
}

@end
