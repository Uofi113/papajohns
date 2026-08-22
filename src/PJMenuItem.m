// PJMenuItem.m
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import "PJMenuItem.h"

@implementation PJMenuItem

+ (instancetype)itemFromDictionary:(NSDictionary *)dict {
    PJMenuItem *item = [[PJMenuItem alloc] init];
    item.itemId          = [dict[@"id"] description];
    item.name            = dict[@"name"]        ?: @"";
    item.itemDescription = dict[@"description"] ?: @"";
    item.price           = [dict[@"price"] floatValue];
    item.imageURL        = dict[@"image_url"]   ?: @"";
    return item;
}

@end
