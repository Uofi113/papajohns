// PJNetworkManager.m
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import "PJNetworkManager.h"

static NSString * const kBaseURL        = @"https://api.papajohns.ru/v2";
static NSString * const kPJAuthTokenKey = @"PJAuthToken";

// ── Internal connection delegate ──────────────────────────────────────────
@interface PJConnection : NSObject <NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, copy)   PJSuccessBlock success;
@property (nonatomic, copy)   PJFailureBlock failure;
@end

@implementation PJConnection

- (instancetype)init {
    self = [super init];
    if (self) _data = [NSMutableData data];
    return self;
}

- (void)connection:(NSURLConnection *)c didReceiveData:(NSData *)d {
    [_data appendData:d];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)c {
    NSError *err = nil;
    id json = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&err];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (err) { if (_failure) _failure(err); }
        else      { if (_success) _success(json); }
    });
}

- (void)connection:(NSURLConnection *)c didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_failure) _failure(error);
    });
}
@end

// ── Manager ───────────────────────────────────────────────────────────────
@interface PJNetworkManager ()
@property (nonatomic, strong) NSMutableArray *activeConnections;
@end

@implementation PJNetworkManager

+ (instancetype)sharedManager {
    static PJNetworkManager *inst;
    static dispatch_once_t tok;
    dispatch_once(&tok, ^{ inst = [[self alloc] init]; });
    return inst;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _activeConnections = [NSMutableArray array];
        _authToken = [[NSUserDefaults standardUserDefaults] stringForKey:kPJAuthTokenKey];
    }
    return self;
}

- (void)setAuthToken:(NSString *)token {
    _authToken = [token copy];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kPJAuthTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// ── GET ───────────────────────────────────────────────────────────────────
- (void)GET:(NSString *)path parameters:(NSDictionary *)params
    success:(PJSuccessBlock)success failure:(PJFailureBlock)failure
{
    NSString *url = [kBaseURL stringByAppendingString:path];
    if (params.count) {
        NSMutableArray *parts = [NSMutableArray array];
        [params enumerateKeysAndObjectsUsingBlock:^(id k, id v, BOOL *s) {
            [parts addObject:[NSString stringWithFormat:@"%@=%@",
                [k stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                [[v description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }];
        url = [url stringByAppendingFormat:@"?%@", [parts componentsJoinedByString:@"&"]];
    }
    NSMutableURLRequest *req = [NSMutableURLRequest
        requestWithURL:[NSURL URLWithString:url]
           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
       timeoutInterval:30.f];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if (_authToken)
        [req setValue:[NSString stringWithFormat:@"Bearer %@", _authToken]
   forHTTPHeaderField:@"Authorization"];
    [self _sendRequest:req success:success failure:failure];
}

// ── POST ──────────────────────────────────────────────────────────────────
- (void)POST:(NSString *)path parameters:(NSDictionary *)params
     success:(PJSuccessBlock)success failure:(PJFailureBlock)failure
{
    NSMutableURLRequest *req = [NSMutableURLRequest
        requestWithURL:[NSURL URLWithString:[kBaseURL stringByAppendingString:path]]
           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
       timeoutInterval:30.f];
    req.HTTPMethod = @"POST";
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if (_authToken)
        [req setValue:[NSString stringWithFormat:@"Bearer %@", _authToken]
   forHTTPHeaderField:@"Authorization"];
    if (params)
        req.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [self _sendRequest:req success:success failure:failure];
}

- (void)_sendRequest:(NSURLRequest *)req
             success:(PJSuccessBlock)success failure:(PJFailureBlock)failure
{
    PJConnection *conn = [[PJConnection alloc] init];
    conn.success = success;
    conn.failure = failure;
    [_activeConnections addObject:conn];
    NSURLConnection *c = [[NSURLConnection alloc]
        initWithRequest:req delegate:conn startImmediately:NO];
    [c scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [c start];
}

// ── Auth ──────────────────────────────────────────────────────────────────
- (void)sendOTPToPhone:(NSString *)phone
               success:(PJSuccessBlock)success failure:(PJFailureBlock)failure
{
    [self POST:@"/auth/phone/request"
    parameters:@{@"phone": phone}
       success:success failure:failure];
}

- (void)verifyOTP:(NSString *)code phone:(NSString *)phone
          success:(PJSuccessBlock)success failure:(PJFailureBlock)failure
{
    [self POST:@"/auth/phone/confirm"
    parameters:@{@"phone": phone, @"code": code}
       success:^(id resp) {
           NSString *token = resp[@"token"];
           if (token) self.authToken = token;
           if (success) success(resp);
       } failure:failure];
}

// ── Catalog ───────────────────────────────────────────────────────────────
- (void)fetchMenuWithSuccess:(PJSuccessBlock)success failure:(PJFailureBlock)failure {
    [self GET:@"/menu" parameters:nil success:success failure:failure];
}

- (void)fetchProduct:(NSString *)pid success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {
    NSString *path = [@"/products/" stringByAppendingString:pid];
    [self GET:path parameters:nil success:success failure:failure];
}

// ── Orders ────────────────────────────────────────────────────────────────
- (void)placeOrder:(NSDictionary *)data
           success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {
    [self POST:@"/orders" parameters:data success:success failure:failure];
}

@end
