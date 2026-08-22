// PJCartItem.m
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import "PJCartItem.h"

@implementation PJCartItem

- (instancetype)initWithMenuItem:(PJMenuItem *)item {
    self = [super init];
    if (self) { _menuItem = item; _quantity = 1; }
    return self;
}

- (CGFloat)totalPrice { return _menuItem.price * _quantity; }

@end
