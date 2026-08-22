// PJAuthViewController.m
// Папаша Беппе iOS 6 client
// (c) uofist | tg: @uofist
//
// РЎРєРµРІРѕРјРѕСЂС„РЅС‹Р№ СЌРєСЂР°РЅ РІС…РѕРґР°: РєСЂР°СЃРЅС‹Р№ РєРѕР¶Р°РЅС‹Р№ С„РѕРЅ, СЃС‚РµРєР»СЏРЅРЅР°СЏ РєР°СЂС‚РѕС‡РєР°.

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

    // в”Ђв”Ђ Р¤РѕРЅ: РєСЂР°СЃРЅС‹Р№ РєРѕР¶Р°РЅС‹Р№ РіСЂР°РґРёРµРЅС‚ в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    CAGradientLayer *bg = [CAGradientLayer layer];
    bg.frame = self.view.bounds;
    bg.colors = @[
        (id)[UIColor colorWithRed:0.52f green:0.05f blue:0.05f alpha:1.f].CGColor,
        (id)[UIColor colorWithRed:0.12f green:0.01f blue:0.01f alpha:1.f].CGColor
    ];
    [self.view.layer insertSublayer:bg atIndex:0];

    // С€СѓРј-С‚РµРєСЃС‚СѓСЂР° РїРѕРІРµСЂС… (РёРјРёС‚Р°С†РёСЏ РєРѕР¶Рё)
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

    // в”Ђв”Ђ Р›РѕРіРѕС‚РёРї в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(20.f, 60.f, W - 40.f, 70.f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    logoView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"]];
    [self.view addSubview:logoView];

    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(20.f, 140.f, W - 40.f, 20.f)];
    hint.backgroundColor = [UIColor clearColor];
    hint.text          = @"Р’РѕР№РґРёС‚Рµ, С‡С‚РѕР±С‹ РѕС„РѕСЂРјРёС‚СЊ Р·Р°РєР°Р·";
    hint.font          = [UIFont systemFontOfSize:13.f];
    hint.textColor     = [UIColor colorWithWhite:1.f alpha:0.55f];
    hint.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:hint];

    // в”Ђв”Ђ РљР°СЂС‚РѕС‡РєР° в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    CGFloat cW = W - 40.f;
    _card = [[UIView alloc] initWithFrame:CGRectMake(20.f, 172.f, cW, 260.f)];
    _card.backgroundColor    = [UIColor colorWithWhite:1.f alpha:0.10f];
    _card.layer.cornerRadius = 14.f;
    _card.layer.borderColor  = [UIColor colorWithWhite:1.f alpha:0.22f].CGColor;
    _card.layer.borderWidth  = 1.f;
    [self.view addSubview:_card];

    CGFloat pad = 15.f;

    // РўРµР»РµС„РѕРЅ
    _phoneField = [[UITextField alloc] initWithFrame:CGRectMake(pad, 18.f, cW - pad*2, 46.f)];
    _phoneField.borderStyle = UITextBorderStyleRoundedRect;
    _phoneField.placeholder   = @"+7 (___) ___-__-__";
    _phoneField.keyboardType  = UIKeyboardTypePhonePad;
    _phoneField.textAlignment = NSTextAlignmentCenter;
    _phoneField.font          = [UIFont systemFontOfSize:18.f];
    [_card addSubview:_phoneField];

    // РљРЅРѕРїРєР° "РџРѕР»СѓС‡РёС‚СЊ РєРѕРґ"
    _sendBtn = [[PJGlossButton alloc] initWithFrame:CGRectMake(pad, 76.f, cW - pad*2, 46.f)];
    [_sendBtn setTitle:@"РџРѕР»СѓС‡РёС‚СЊ РєРѕРґ" forState:UIControlStateNormal];
    _sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    [_sendBtn addTarget:self action:@selector(_sendOTP) forControlEvents:UIControlEventTouchUpInside];
    [_card addSubview:_sendBtn];

    // OTP РїРѕР»Рµ (СЃРєСЂС‹С‚Рѕ)
    _otpField = [[UITextField alloc] initWithFrame:CGRectMake(pad, 136.f, cW - pad*2, 46.f)];
    _otpField.borderStyle = UITextBorderStyleRoundedRect;
    _otpField.placeholder   = @"РљРѕРґ РёР· SMS";
    _otpField.keyboardType  = UIKeyboardTypeNumberPad;
    _otpField.textAlignment = NSTextAlignmentCenter;
    _otpField.font          = [UIFont boldSystemFontOfSize:26.f];
    _otpField.hidden        = YES;
    [_card addSubview:_otpField];

    // РљРЅРѕРїРєР° "Р’РѕР№С‚Рё" (СЃРєСЂС‹С‚Рѕ)
    _verifyBtn = [[PJGlossButton alloc] initWithFrame:CGRectMake(pad, 194.f, cW - pad*2, 46.f)];
    [_verifyBtn setTitle:@"Р’РѕР№С‚Рё" forState:UIControlStateNormal];
    _verifyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    [_verifyBtn addTarget:self action:@selector(_verifyOTP) forControlEvents:UIControlEventTouchUpInside];
    _verifyBtn.hidden = YES;
    [_card addSubview:_verifyBtn];

    // РЎРїРёРЅРЅРµСЂ
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center           = CGPointMake(W / 2.f, 460.f);
    _spinner.hidesWhenStopped = YES;
    [self.view addSubview:_spinner];

    // РЎРєСЂС‹С‚РёРµ РєР»Р°РІРёР°С‚СѓСЂС‹ РїРѕ С‚Р°РїСѓ
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(_dismissKbd)];
    [self.view addGestureRecognizer:tap];
}

// в”Ђв”Ђ РћС‚РїСЂР°РІРёС‚СЊ OTP в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
- (void)_sendOTP {
    NSString *phone = [_phoneField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (phone.length < 10) { [self _alert:@"Р’РІРµРґРёС‚Рµ РЅРѕРјРµСЂ С‚РµР»РµС„РѕРЅР°"]; return; }

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

// в”Ђв”Ђ РџСЂРѕРІРµСЂРёС‚СЊ OTP в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
- (void)_verifyOTP {
    NSString *phone = [_phoneField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *code  = [_otpField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (code.length < 4) { [self _alert:@"Р’РІРµРґРёС‚Рµ РєРѕРґ РёР· SMS"]; return; }

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
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"РћС€РёР±РєР°"
                                                message:msg
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    [a show];
}

- (void)_dismissKbd { [self.view endEditing:YES]; }

@end

