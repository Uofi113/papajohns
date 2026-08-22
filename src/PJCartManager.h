// PJCartManager.h
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import <Foundation/Foundation.h>
#import "PJCartItem.h"
#import "PJMenuItem.h"

extern NSString * const PJCartDidUpdateNotification;

@interface PJCartManager : NSObject
+ (instancetype)sharedManager;
@property (nonatomic, readonly) NSArray   *cartItems;
@property (nonatomic, readonly) NSInteger  totalCount;
@property (nonatomic, readonly) CGFloat    totalPrice;
- (void)addItem:(PJMenuItem *)item;
- (void)removeItem:(PJMenuItem *)item;
- (void)incrementItem:(PJMenuItem *)item;
- (void)decrementItem:(PJMenuItem *)item;
- (void)clearCart;
- (PJCartItem *)cartItemForMenuItem:(PJMenuItem *)item;
@end
