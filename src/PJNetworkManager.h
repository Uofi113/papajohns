// PJNetworkManager.h
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import <Foundation/Foundation.h>

typedef void (^PJSuccessBlock)(id responseObject);
typedef void (^PJFailureBlock)(NSError *error);

@interface PJNetworkManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, copy) NSString *authToken;

// Generic
- (void)GET:(NSString *)path parameters:(NSDictionary *)params
    success:(PJSuccessBlock)success failure:(PJFailureBlock)failure;
- (void)POST:(NSString *)path parameters:(NSDictionary *)params
     success:(PJSuccessBlock)success failure:(PJFailureBlock)failure;

// Auth
- (void)sendOTPToPhone:(NSString *)phone
               success:(PJSuccessBlock)success failure:(PJFailureBlock)failure;
- (void)verifyOTP:(NSString *)code phone:(NSString *)phone
          success:(PJSuccessBlock)success failure:(PJFailureBlock)failure;

// Catalog
- (void)fetchMenuWithSuccess:(PJSuccessBlock)success failure:(PJFailureBlock)failure;
- (void)fetchProduct:(NSString *)productId
             success:(PJSuccessBlock)success failure:(PJFailureBlock)failure;

// Orders
- (void)placeOrder:(NSDictionary *)orderData
           success:(PJSuccessBlock)success failure:(PJFailureBlock)failure;

@end
