// PJAuthViewController.m
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist
//
// Скевоморфный экран входа: красный кожаный фон, стеклянная карточка.

#import "PJAuthViewController.h"
#import "PJNetworkManager.h"
#import "PJGlossButton.h"
#import <QuartzCore/QuartzCore.h>

@interface PJAuthViewController ()
@property (nonatomic, strong) UITextField            *phoneField;
@property (nonatomic, strong) UITextField            *otpField;
@property (nonatomic, strong) PJGlossButton          *sendBtn;
@property (nonatomic, strong) PJGlossButton          *verifyBtn;
@property (nonatomic, strong) UIView                 *card;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation PJAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat W = self.view.bounds.size.width;

    // ── Фон: красный кожаный градиент ──────────────────────────────────
    CAGradientLayer *bg = [CAGradientLayer layer];
    bg.frame = self.view.bounds;
    bg.colors = @[
        (id)[UIColor colorWithRed:0.52f green:0.05f blue:0.05f alpha:1.f].CGColor,
        (id)[UIColor colorWithRed:0.12f green:0.01f blue:0.01f alpha:1.f].CGColor
    ];
    [self.view.layer insertSublayer:bg atIndex:0];

    // шум-текстура поверх (имитация кожи)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(4, 4), NO, 0);
    srand48(7);
    for (int i = 0; i < 16; i++) {
        CGFloat a = drand48() * 0.06f;
        [[UIColor colorWithWhite:(i % 2 ? 0.f : 1.f) alpha:a] setFill];
        UIRectFill(CGRectMake(i % 4, i / 4, 1, 1));
    }
    UIImage *noise = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CALayer *nl = [CALayer layer];
    nl.frame    = self.view.bounds;
    nl.contents = (id)noise.CGImage;
    nl.contentsGravity = kCAGravityResize;
    [self.view.layer insertSublayer:nl atIndex:1];

    // ── Логотип ──────────────────────────────────────────────────────────
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(20.f, 60.f, W - 40.f, 70.f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"]];
    [self.view addSubview:logoView];

    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(20.f, 140.f, W - 40.f, 20.f)];
    hint.backgroundColor = [UIColor clearColor];
    hint.text          = @"Войдите, чтобы оформить заказ";
    hint.font          = [UIFont systemFontOfSize:13.f];
    hint.textColor     = [UIColor colorWithWhite:1.f alpha:0.55f];
    hint.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:hint];

    // ── Карточка ─────────────────────────────────────────────────────────
    CGFloat cW = W - 40.f;
    _card = [[UIView alloc] initWithFrame:CGRectMake(20.f, 172.f, cW, 260.f)];
    _card.backgroundColor    = [UIColor colorWithWhite:1.f alpha:0.10f];
    _card.layer.cornerRadius = 14.f;
    _card.layer.borderColor  = [UIColor colorWithWhite:1.f alpha:0.22f].CGColor;
    _card.layer.borderWidth  = 1.f;
    [self.view addSubview:_card];

    CGFloat pad = 15.f;

    // Телефон
    _phoneField = [[UITextField alloc] initWithFrame:CGRectMake(pad, 18.f, cW - pad*2, 46.f)];
    _phoneField.borderStyle = UITextBorderStyleRoundedRect;
    _phoneField.placeholder   = @"+7 (___) ___-__-__";
    _phoneField.keyboardType  = UIKeyboardTypePhonePad;
    _phoneField.textAlignment = NSTextAlignmentCenter;
    _phoneField.font          = [UIFont systemFontOfSize:18.f];
    [_card addSubview:_phoneField];

    // Кнопка "Получить код"
    _sendBtn = [[PJGlossButton alloc] initWithFrame:CGRectMake(pad, 76.f, cW - pad*2, 46.f)];
    [_sendBtn setTitle:@"Получить код" forState:UIControlStateNormal];
    _sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    [_sendBtn addTarget:self action:@selector(_sendOTP) forControlEvents:UIControlEventTouchUpInside];
    [_card addSubview:_sendBtn];

    // OTP поле (скрыто)
    _otpField = [[UITextField alloc] initWithFrame:CGRectMake(pad, 136.f, cW - pad*2, 46.f)];
    _otpField.borderStyle = UITextBorderStyleRoundedRect;
    _otpField.placeholder   = @"Код из SMS";
    _otpField.keyboardType  = UIKeyboardTypeNumberPad;
    _otpField.textAlignment = NSTextAlignmentCenter;
    _otpField.font          = [UIFont boldSystemFontOfSize:26.f];
    _otpField.hidden        = YES;
    [_card addSubview:_otpField];

    // Кнопка "Войти" (скрыто)
    _verifyBtn = [[PJGlossButton alloc] initWithFrame:CGRectMake(pad, 194.f, cW - pad*2, 46.f)];
    [_verifyBtn setTitle:@"Войти" forState:UIControlStateNormal];
    _verifyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    [_verifyBtn addTarget:self action:@selector(_verifyOTP) forControlEvents:UIControlEventTouchUpInside];
    _verifyBtn.hidden = YES;
    [_card addSubview:_verifyBtn];

    // Спиннер
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center           = CGPointMake(W / 2.f, 460.f);
    _spinner.hidesWhenStopped = YES;
    [self.view addSubview:_spinner];

    // Скрытие клавиатуры по тапу
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(_dismissKbd)];
    [self.view addGestureRecognizer:tap];
}

// ── Отправить OTP ─────────────────────────────────────────────────────────
- (void)_sendOTP {
    NSString *phone = [_phoneField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (phone.length < 10) { [self _alert:@"Введите номер телефона"]; return; }

    _sendBtn.enabled = NO;
    [_spinner startAnimating];

    [[PJNetworkManager sharedManager] sendOTPToPhone:phone
        success:^(id resp) {
            [_spinner stopAnimating];
            _sendBtn.enabled = YES;
            [UIView animateWithDuration:0.25f animations:^{
                _otpField.hidden   = NO;
                _verifyBtn.hidden  = NO;
            }];
            [_otpField becomeFirstResponder];
        }
        failure:^(NSError *err) {
            [_spinner stopAnimating];
            _sendBtn.enabled = YES;
            [self _alert:err.localizedDescription];
        }];
}

// ── Проверить OTP ─────────────────────────────────────────────────────────
- (void)_verifyOTP {
    NSString *phone = [_phoneField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *code  = [_otpField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (code.length < 4) { [self _alert:@"Введите код из SMS"]; return; }

    _verifyBtn.enabled = NO;
    [_spinner startAnimating];

    [[PJNetworkManager sharedManager] verifyOTP:code phone:phone
        success:^(id resp) {
            [_spinner stopAnimating];
            if (_onAuthSuccess) _onAuthSuccess();
        }
        failure:^(NSError *err) {
            [_spinner stopAnimating];
            _verifyBtn.enabled = YES;
            [self _alert:err.localizedDescription];
        }];
}

- (void)_alert:(NSString *)msg {
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                message:msg
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    [a show];
}

- (void)_dismissKbd { [self.view endEditing:YES]; }

@end
