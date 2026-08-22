// PJPromoItem.h
#import <Foundation/Foundation.h>

@interface PJPromoItem : NSObject
@property (nonatomic, copy) NSString *promoId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *teaser;
@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, copy) NSString *imageURL;

+ (instancetype)itemFromDictionary:(NSDictionary *)dict;
@end