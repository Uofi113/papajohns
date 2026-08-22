// PJGlossButton.m
// Папаша Беппе iOS 6 client
// (c) uofist | tg: @uofist

#import "PJGlossButton.h"

static UIColor *PJBtnTopColor(void) {
    return [UIColor colorWithRed:0.85f green:0.10f blue:0.10f alpha:1.f];
}
static UIColor *PJBtnBotColor(void) {
    return [UIColor colorWithRed:0.55f green:0.02f blue:0.02f alpha:1.f];
}

@interface PJGlossButton ()
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAGradientLayer *glossLayer;
@end

@implementation PJGlossButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.clipsToBounds      = YES;
    self.layer.cornerRadius = 6.f;
    self.layer.borderColor  = [UIColor colorWithRed:0.35f green:0.f blue:0.f alpha:1.f].CGColor;
    self.layer.borderWidth  = 1.f;

    // в”Ђв”Ђ РѕСЃРЅРѕРІРЅРѕР№ РіСЂР°РґРёРµРЅС‚ в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.colors = @[
        (id)PJBtnTopColor().CGColor,
        (id)PJBtnBotColor().CGColor
    ];
    _gradientLayer.locations = @[@0.f, @1.f];
    [self.layer insertSublayer:_gradientLayer atIndex:0];

    // в”Ђв”Ђ Р±Р»РёРє: РІРµСЂС…РЅСЏСЏ РїРѕР»РѕРІРёРЅР° в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    _glossLayer = [CAGradientLayer layer];
    _glossLayer.colors = @[
        (id)[UIColor colorWithWhite:1.f alpha:0.35f].CGColor,
        (id)[UIColor colorWithWhite:1.f alpha:0.05f].CGColor
    ];
    _glossLayer.locations = @[@0.f, @1.f];
    [self.layer insertSublayer:_glossLayer above:_gradientLayer];

    // в”Ђв”Ђ РІРґР°РІР»РµРЅРЅС‹Р№ С‚РµРєСЃС‚ в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    self.titleLabel.font         = [UIFont boldSystemFontOfSize:13.f];
    self.titleLabel.shadowColor  = [UIColor colorWithWhite:1.f alpha:0.5f];
    self.titleLabel.shadowOffset = CGSizeMake(0.f, 1.f);
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitle:@"Р’ РєРѕСЂР·РёРЅСѓ" forState:UIControlStateNormal];

    [self addTarget:self action:@selector(_touchDown)
   forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(_touchUp)
   forControlEvents:UIControlEventTouchUpInside  | UIControlEventTouchUpOutside
                    | UIControlEventTouchDragExit | UIControlEventTouchCancel];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradientLayer.frame = self.bounds;

    CGRect gloss      = self.bounds;
    gloss.size.height = floorf(self.bounds.size.height * 0.52f);
    _glossLayer.frame = gloss;
}

- (void)_touchDown { _gradientLayer.opacity = 0.7f; }
- (void)_touchUp   { _gradientLayer.opacity = 1.0f; }

@end

