#import "PJNetworkManager.h"

@implementation PJNetworkManager
+ (instancetype)sharedManager {
    static PJNetworkManager *inst;
    static dispatch_once_t tok;
    dispatch_once(&tok, ^{ inst = [[self alloc] init]; });
    return inst;
}

- (void)fetchMenuWithSuccess:(PJSuccessBlock)success failure:(PJFailureBlock)failure {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *items = @[
            @{@"id": @"1", @"name": @"Папаша Беппе", @"description": @"Фирменная пицца с ветчиной, пепперони, грибами", @"price": @(840), @"image_url": @"local://pep.jpg"},
            @{@"id": @"2", @"name": @"Груша и Дор Блю", @"description": @"Изысканная пицца со сладкой грушей, сыром Дор Блю", @"price": @(650), @"image_url": @"local://marg.jpg"},
            @{@"id": @"3", @"name": @"Мясной пир", @"description": @"Бекон, салями, ветчина, охотничьи колбаски", @"price": @(890), @"image_url": @"local://meat.jpg"}
        ];
        if (success) success(@{@"items": items});
    });
}
- (void)fetchProduct:(NSString *)pid success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {}
- (void)sendOTPToPhone:(NSString *)phone success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {}
- (void)verifyOTP:(NSString *)code phone:(NSString *)phone success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {}
- (void)placeOrder:(NSDictionary *)data success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {}

- (void)GET:(NSString *)path parameters:(NSDictionary *)params success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {}
- (void)POST:(NSString *)path parameters:(NSDictionary *)params success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {}

@end
