#import <Foundation/Foundation.h>

@interface PJMenuItem : NSObject
@property (nonatomic, copy)   NSString  *itemId;
@property (nonatomic, copy)   NSString  *name;
@property (nonatomic, copy)   NSString  *itemDescription;
@property (nonatomic, assign) CGFloat    price;
@property (nonatomic, copy)   NSString  *imageURL;

+ (instancetype)itemFromDictionary:(NSDictionary *)dict;
@end
