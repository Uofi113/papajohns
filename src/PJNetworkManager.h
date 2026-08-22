#import <Foundation/Foundation.h>

typedef void (^PJSuccessBlock)(id responseObject);
typedef void (^PJFailureBlock)(NSError *error);

@interface PJNetworkManager : NSObject

+ (instancetype)sharedManager;

- (void)GET:(NSString *)urlString
 parameters:(NSDictionary *)params
    success:(PJSuccessBlock)success
    failure:(PJFailureBlock)failure;

- (void)POST:(NSString *)urlString
  parameters:(NSDictionary *)params
     success:(PJSuccessBlock)success
     failure:(PJFailureBlock)failure;

@end
