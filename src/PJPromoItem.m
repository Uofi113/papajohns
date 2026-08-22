// PJPromoItem.m
#import "PJPromoItem.h"

@implementation PJPromoItem

+ (instancetype)itemFromDictionary:(NSDictionary *)dict {
    PJPromoItem *item = [[PJPromoItem alloc] init];
    item.promoId          = [dict[@"id"] description] ?: @"";
    item.title            = dict[@"title"]       ?: @"";
    item.teaser           = dict[@"teaser"]      ?: @"";
    item.itemDescription  = dict[@"description"] ?: @"";
    item.imageURL         = dict[@"image_url"]   ?: @"";
    return item;
}

@end