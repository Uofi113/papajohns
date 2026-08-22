// PJNetworkManager.m
// Папаша Беппе iOS 6 client
// (c) uofist | tg: @uofist

#import "PJNetworkManager.h"

static NSString * const kBaseURL        = @"https://raw.githubusercontent.com/Uofi113/papajohns/main";
static NSString * const kPJAuthTokenKey = @"PJAuthToken";

// в”Ђв”Ђ Internal connection delegate в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
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
        if (err) {
            NSString *raw = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
            NSString *msg = [NSString stringWithFormat:@"API РЅРµ РІРµСЂРЅСѓР» JSON. РћС‚РІРµС‚: %@", raw ? [raw substringToIndex:MIN(raw.length, 100)] : @""];
            NSError *customErr = [NSError errorWithDomain:@"PJErrorDomain" code:err.code userInfo:@{NSLocalizedDescriptionKey: msg}];
            if (_failure) _failure(customErr);
        }
        else { if (_success) _success(json); }
    });
}

- (void)connection:(NSURLConnection *)c didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_failure) _failure(error);
    });
}
@end

// в”Ђв”Ђ Manager в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
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

- (void)setAuthToken:(NSString *)authToken {
    _authToken = [authToken copy];
    if (authToken) {
        [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:kPJAuthTokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPJAuthTokenKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// в”Ђв”Ђ Helpers в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
- (NSMutableURLRequest *)_requestWithPath:(NSString *)path method:(NSString *)method {
    NSString *urlStr = [kBaseURL stringByAppendingString:path];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    req.HTTPMethod = method;
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // Папаша Беппе headers based on typical app
    [req setValue:@"ios" forHTTPHeaderField:@"X-App-Type"];
    if (_authToken) {
        NSString *authVal = [NSString stringWithFormat:@"Bearer %@", _authToken];
        [req setValue:authVal forHTTPHeaderField:@"Authorization"];
    }
    return req;
}

// в”Ђв”Ђ GET в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
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

// в”Ђв”Ђ POST в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
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

// в”Ђв”Ђ Auth в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
- (void)sendOTPToPhone:(NSString *)phone
               success:(PJSuccessBlock)success failure:(PJFailureBlock)failure
{
    [self GET:@"/auth.json"
    parameters:nil
       success:success failure:failure];
}

- (void)verifyOTP:(NSString *)code phone:(NSString *)phone
          success:(PJSuccessBlock)success failure:(PJFailureBlock)failure
{
    [self GET:@"/auth.json"
    parameters:nil
       success:^(id resp) {
           NSString *token = resp[@"token"];
           if (token) self.authToken = token;
           if (success) success(resp);
       } failure:failure];
}

// в”Ђв”Ђ Catalog в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
- (void)fetchMenuWithSuccess:(PJSuccessBlock)success failure:(PJFailureBlock)failure {
    [self GET:@"/menu.json" parameters:nil success:success failure:failure];
}

- (void)fetchProduct:(NSString *)pid success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {
    [self GET:@"/menu.json" parameters:nil success:success failure:failure];
}

// в”Ђв”Ђ Orders в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
- (void)placeOrder:(NSDictionary *)data
           success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {
    [self GET:@"/orders.json" parameters:nil success:success failure:failure];
}

@end

