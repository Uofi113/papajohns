// PJMenuCell.h
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PJMenuItem.h"
#import "PJGlossButton.h"

typedef void (^PJAddToCartBlock)(PJMenuItem *item);

@interface PJMenuCell : UITableViewCell
@property (nonatomic, copy) PJAddToCartBlock addToCartBlock;
- (void)configureWithItem:(PJMenuItem *)item;
+ (CGFloat)cellHeight;
@end
