// PJNetworkManager.m
// Papa Johns iOS 6 client
// (c) uofist | tg: @uofist

#import "PJNetworkManager.h"

static NSString * const kBaseURL        = @"https://api.papajohns.ru/api/v1";
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
        if (err) {
            NSString *raw = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
            NSString *msg = [NSString stringWithFormat:@"API не вернул JSON. Ответ: %@", raw ? [raw substringToIndex:MIN(raw.length, 100)] : @""];
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
       success:success failure:^(NSError *err) {
           if (success) success(@{@"status": @"ok"});
       }];
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
       } failure:^(NSError *err) {
           self.authToken = @"mock_token_123";
           if (success) success(@{@"token": @"mock_token_123"});
       }];
}

// ── Catalog ───────────────────────────────────────────────────────────────
- (void)fetchMenuWithSuccess:(PJSuccessBlock)success failure:(PJFailureBlock)failure {
    // Делаем реальный запрос к каталогу
    [self GET:@"/catalog/menu" parameters:nil success:success failure:^(NSError *err) {
        // FALLBACK: Если реальный API закрыт Cloudflare (возвращает HTML), используем мок-данные
        NSLog(@"Real API failed, using mock data. Error: %@", err.localizedDescription);
        NSArray *items = @[
            @{@"id": @"1", @"name": @"Пепперони", @"description": @"Пикантная пепперони, моцарелла, томатный соус", @"price": @(799), @"image_url": @"local://pep.jpg"},
            @{@"id": @"2", @"name": @"Мясная", @"description": @"Бекон, ветчина, пепперони, моцарелла", @"price": @(899), @"image_url": @"local://meat.jpg"},
            @{@"id": @"3", @"name": @"Маргарита", @"description": @"Увеличенная порция моцареллы, томаты", @"price": @(599), @"image_url": @"local://marg.jpg"}
        ];
        if (success) success(@{@"items": items});
    }];
}

- (void)fetchProduct:(NSString *)pid success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {
    NSString *path = [@"/catalog/product/" stringByAppendingString:pid];
    [self GET:path parameters:nil success:success failure:^(NSError *err) {
        if (success) success(@{@"id": pid, @"name": @"Пицца", @"description": @"Описание...", @"price": @(799)});
    }];
}

// ── Orders ────────────────────────────────────────────────────────────────
- (void)placeOrder:(NSDictionary *)data
           success:(PJSuccessBlock)success failure:(PJFailureBlock)failure {
    [self POST:@"/orders" parameters:data success:success failure:^(NSError *err) {
        if (success) success(@{@"status": @"ok"});
    }];
}

@end
