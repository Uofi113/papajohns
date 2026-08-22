// PJPromoViewController.h
#import <UIKit/UIKit.h>
#import "PJPromoItem.h"

@interface PJPromoViewController : UITableViewController
@property (nonatomic, strong) NSArray *promos;
- (void)reloadWithPromos:(NSArray *)promos;
@end