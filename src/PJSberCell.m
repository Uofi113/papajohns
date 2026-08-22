// PJSberCell.m
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import "PJSberCell.h"

@interface PJSberCell ()
@property (nonatomic, strong) UIView          *card;
@property (nonatomic, strong) CAGradientLayer *grad;
@end

@implementation PJSberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.selectionStyle          = UITableViewCellSelectionStyleNone;
    self.userInteractionEnabled  = NO;   // нельзя тапнуть
    self.backgroundColor         = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

    // ── Зелёная карточка Сбера ─────────────────────────────────────────
    _card = [[UIView alloc] init];
    _card.layer.cornerRadius  = 10.f;
    _card.clipsToBounds        = NO;
    _card.layer.shadowColor    = [UIColor blackColor].CGColor;
    _card.layer.shadowOpacity  = 0.30f;
    _card.layer.shadowRadius   = 5.f;
    _card.layer.shadowOffset   = CGSizeMake(0.f, 2.f);
    [self.contentView addSubview:_card];

    // Sber green: #21A038 → #108228
    _grad = [CAGradientLayer layer];
    _grad.colors = @[
        (id)[UIColor colorWithRed:0.13f green:0.63f blue:0.22f alpha:1.f].CGColor,
        (id)[UIColor colorWithRed:0.063f green:0.51f blue:0.16f alpha:1.f].CGColor
    ];
    _grad.cornerRadius = 10.f;
    [_card.layer insertSublayer:_grad atIndex:0];

    // Иконка замка
    UILabel *lock = [[UILabel alloc] init];
    lock.text          = @"🔒";
    lock.font          = [UIFont systemFontOfSize:34.f];
    lock.textAlignment = NSTextAlignmentCenter;
    lock.tag           = 10;
    [_card addSubview:lock];

    // Заголовок
    UILabel *title = [[UILabel alloc] init];
    title.text         = @"Телефон за 1000 бонусов";
    title.font         = [UIFont boldSystemFontOfSize:15.f];
    title.textColor    = [UIColor whiteColor];
    title.shadowColor  = [UIColor colorWithWhite:0.f alpha:0.35f];
    title.shadowOffset = CGSizeMake(0.f, 1.f);
    title.tag          = 11;
    [_card addSubview:title];

    // Подзаголовок
    UILabel *sub = [[UILabel alloc] init];
    sub.text      = @"СберСпасибо";
    sub.font      = [UIFont systemFontOfSize:12.f];
    sub.textColor = [UIColor colorWithWhite:1.f alpha:0.72f];
    sub.tag       = 12;
    [_card addSubview:sub];

    // Цена (жёлтым, как бонусы)
    UILabel *price = [[UILabel alloc] init];
    price.text         = @"1 000 б   СберСпасибо";
    price.font         = [UIFont boldSystemFontOfSize:17.f];
    price.textColor    = [UIColor colorWithRed:1.f green:0.92f blue:0.f alpha:1.f];
    price.shadowColor  = [UIColor colorWithWhite:0.f alpha:0.35f];
    price.shadowOffset = CGSizeMake(0.f, 1.f);
    price.tag          = 13;
    [_card addSubview:price];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat W = self.contentView.bounds.size.width;
    _card.frame = CGRectMake(10.f, 8.f, W - 20.f, [PJSberCell cellHeight] - 16.f);
    _grad.frame = _card.bounds;

    UIBezierPath *sp = [UIBezierPath bezierPathWithRoundedRect:_card.bounds cornerRadius:10.f];
    _card.layer.shadowPath = sp.CGPath;

    CGFloat iconW = 64.f;
    CGFloat cx    = iconW + 8.f;
    CGFloat cw    = _card.bounds.size.width - cx - 12.f;
    CGFloat ch    = _card.bounds.size.height;

    for (UIView *v in _card.subviews) {
        if (![v isKindOfClass:[UILabel class]]) continue;
        UILabel *l = (UILabel *)v;
        switch (l.tag) {
            case 10: l.frame = CGRectMake(0.f, (ch - iconW)/2.f, iconW, iconW); break;
            case 11: l.frame = CGRectMake(cx, 12.f, cw, 22.f); break;
            case 12: l.frame = CGRectMake(cx, 34.f, cw, 18.f); break;
            case 13: l.frame = CGRectMake(cx, 54.f, cw, 22.f); break;
        }
    }
}

+ (CGFloat)cellHeight { return 100.f; }

@end
