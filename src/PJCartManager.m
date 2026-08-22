// PJCartManager.m
// Папаша Беппе iOS 6 client
// (c) uofist | tg: @uofist

#import "PJCartManager.h"

NSString * const PJCartDidUpdateNotification = @"PJCartDidUpdateNotification";

@interface PJCartManager ()
@property (nonatomic, strong) NSMutableArray *mutableItems;
@end

@implementation PJCartManager

+ (instancetype)sharedManager {
    static PJCartManager *inst;
    static dispatch_once_t tok;
    dispatch_once(&tok, ^{ inst = [[self alloc] init]; });
    return inst;
}

- (instancetype)init {
    self = [super init];
    if (self) _mutableItems = [NSMutableArray array];
    return self;
}

- (NSArray *)cartItems { return [_mutableItems copy]; }

- (NSInteger)totalCount {
    NSInteger n = 0;
    for (PJCartItem *ci in _mutableItems) n += ci.quantity;
    return n;
}

- (CGFloat)totalPrice {
    CGFloat t = 0.f;
    for (PJCartItem *ci in _mutableItems) t += ci.totalPrice;
    return t;
}

- (PJCartItem *)cartItemForMenuItem:(PJMenuItem *)item {
    for (PJCartItem *ci in _mutableItems)
        if ([ci.menuItem.itemId isEqualToString:item.itemId]) return ci;
    return nil;
}

- (void)addItem:(PJMenuItem *)item {
    PJCartItem *ex = [self cartItemForMenuItem:item];
    if (ex) { ex.quantity++; }
    else { [_mutableItems addObject:[[PJCartItem alloc] initWithMenuItem:item]]; }
    [self _notify];
}

- (void)removeItem:(PJMenuItem *)item {
    PJCartItem *ci = [self cartItemForMenuItem:item];
    if (ci) { [_mutableItems removeObject:ci]; [self _notify]; }
}

- (void)incrementItem:(PJMenuItem *)item {
    PJCartItem *ci = [self cartItemForMenuItem:item];
    if (ci) { ci.quantity++; [self _notify]; }
}

- (void)decrementItem:(PJMenuItem *)item {
    PJCartItem *ci = [self cartItemForMenuItem:item];
    if (!ci) return;
    if (ci.quantity <= 1) [_mutableItems removeObject:ci];
    else ci.quantity--;
    [self _notify];
}

- (void)clearCart {
    [_mutableItems removeAllObjects];
    [self _notify];
}

- (void)_notify {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PJCartDidUpdateNotification object:self];
}

@end
