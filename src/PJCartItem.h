// PJCartItem.h
// Папаша Беппе iOS 6 client
// (c) uofist | tg: @uofist

#import <Foundation/Foundation.h>
#import "PJMenuItem.h"

@interface PJCartItem : NSObject
@property (nonatomic, strong) PJMenuItem *menuItem;
@property (nonatomic, assign) NSInteger   quantity;
@property (nonatomic, readonly) CGFloat   totalPrice;
- (instancetype)initWithMenuItem:(PJMenuItem *)item;
@end
