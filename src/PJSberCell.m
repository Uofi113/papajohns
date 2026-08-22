// PJSberCell.m
// Папаша Беппе iOS 6 client
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
    self.userInteractionEnabled  = NO;   // РЅРµР»СЊР·СЏ С‚Р°РїРЅСѓС‚СЊ
    self.backgroundColor         = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

    // в”Ђв”Ђ Р—РµР»С‘РЅР°СЏ РєР°СЂС‚РѕС‡РєР° РЎР±РµСЂР° в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    _card = [[UIView alloc] init];
    _card.layer.cornerRadius  = 10.f;
    _card.clipsToBounds        = NO;
    _card.layer.shadowColor    = [UIColor blackColor].CGColor;
    _card.layer.shadowOpacity  = 0.30f;
    _card.layer.shadowRadius   = 5.f;
    _card.layer.shadowOffset   = CGSizeMake(0.f, 2.f);
    [self.contentView addSubview:_card];

    // Sber green: #21A038 в†’ #108228
    _grad = [CAGradientLayer layer];
    _grad.colors = @[
        (id)[UIColor colorWithRed:0.13f green:0.63f blue:0.22f alpha:1.f].CGColor,
        (id)[UIColor colorWithRed:0.063f green:0.51f blue:0.16f alpha:1.f].CGColor
    ];
    _grad.cornerRadius = 10.f;
    [_card.layer insertSublayer:_grad atIndex:0];

    // РљР°СЂС‚РёРЅРєР° С‚РµР»РµС„РѕРЅР°
    UIImageView *phoneIcon = [[UIImageView alloc] init];
    phoneIcon.contentMode = UIViewContentModeScaleAspectFit;
    phoneIcon.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fly_phone" ofType:@"png"]];
    phoneIcon.tag = 10;
    [_card addSubview:phoneIcon];

    // Р—Р°РіРѕР»РѕРІРѕРє
    UILabel *title = [[UILabel alloc] init];
    title.backgroundColor = [UIColor clearColor];
    title.text         = @"РўРµР»РµС„РѕРЅ Р·Р° 1000 Р±РѕРЅСѓСЃРѕРІ";
    title.font         = [UIFont boldSystemFontOfSize:15.f];
    title.textColor    = [UIColor whiteColor];
    title.shadowColor  = [UIColor colorWithWhite:0.f alpha:0.35f];
    title.shadowOffset = CGSizeMake(0.f, 1.f);
    title.tag          = 11;
    [_card addSubview:title];

    // РџРѕРґР·Р°РіРѕР»РѕРІРѕРє
    UILabel *sub = [[UILabel alloc] init];
    sub.backgroundColor = [UIColor clearColor];
    sub.text      = @"РЎР±РµСЂРЎРїР°СЃРёР±Рѕ";
    sub.font      = [UIFont systemFontOfSize:12.f];
    sub.textColor = [UIColor colorWithWhite:1.f alpha:0.72f];
    sub.tag       = 12;
    [_card addSubview:sub];

    // Р¦РµРЅР° (Р¶С‘Р»С‚С‹Рј, РєР°Рє Р±РѕРЅСѓСЃС‹)
    UILabel *price = [[UILabel alloc] init];
    price.backgroundColor = [UIColor clearColor];
    price.text         = @"1 000 Р±   РЎР±РµСЂРЎРїР°СЃРёР±Рѕ";
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
        switch (v.tag) {
            case 10: v.frame = CGRectMake(10.f, (ch - 80.f)/2.f, 60.f, 80.f); break; // С‚РµР»РµС„РѕРЅ
            case 11: v.frame = CGRectMake(cx, 12.f, cw, 22.f); break;
            case 12: v.frame = CGRectMake(cx, 34.f, cw, 18.f); break;
            case 13: v.frame = CGRectMake(cx, 54.f, cw, 22.f); break;
        }
    }
}

+ (CGFloat)cellHeight { return 100.f; }

@end

