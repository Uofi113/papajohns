// PJAuthViewController.h
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import <UIKit/UIKit.h>

typedef void (^PJAuthCompletionBlock)(void);

@interface PJAuthViewController : UIViewController
@property (nonatomic, copy) PJAuthCompletionBlock onAuthSuccess;
@end
