#import "PJNetworkManager.h"

static NSString * const kBaseURL = @"https://api.papajohns.ru/v2";

// ─── internal connection delegate ───────────────────────────────────────────
@interface PJConnection : NSObject <NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSMutableData   *data;
@property (nonatomic, copy)   PJSuccessBlock   success;
@property (nonatomic, copy)   PJFailureBlock   failure;
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
    id json = [NSJSONSerialization JSONObjectWithData:_data
                                             options:0
                                               error:&err];
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

// ─── manager ────────────────────────────────────────────────────────────────
@interface PJNetworkManager ()
@property (nonatomic, strong) NSMutableArray *activeConnections; // retain delegates
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
    if (self) _activeConnections = [NSMutableArray array];
    return self;
}

// ─── GET ────────────────────────────────────────────────────────────────────
- (void)GET:(NSString *)path
 parameters:(NSDictionary *)params
    success:(PJSuccessBlock)success
    failure:(PJFailureBlock)failure
{
    NSString *fullURL = [kBaseURL stringByAppendingString:path];
    if (params.count) {
        NSMutableArray *parts = [NSMutableArray array];
        [params enumerateKeysAndObjectsUsingBlock:^(id k, id v, BOOL *s) {
            [parts addObject:[NSString stringWithFormat:@"%@=%@",
                [k stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                [[v description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }];
        fullURL = [fullURL stringByAppendingFormat:@"?%@",
                   [parts componentsJoinedByString:@"&"]];
    }

    NSMutableURLRequest *req = [NSMutableURLRequest
        requestWithURL:[NSURL URLWithString:fullURL]
           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
       timeoutInterval:30.0];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [self _sendRequest:req success:success failure:failure];
}

// ─── POST ───────────────────────────────────────────────────────────────────
- (void)POST:(NSString *)path
  parameters:(NSDictionary *)params
     success:(PJSuccessBlock)success
     failure:(PJFailureBlock)failure
{
    NSString *fullURL = [kBaseURL stringByAppendingString:path];
    NSMutableURLRequest *req = [NSMutableURLRequest
        requestWithURL:[NSURL URLWithString:fullURL]
           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
       timeoutInterval:30.0];
    req.HTTPMethod = @"POST";
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    if (params) {
        req.HTTPBody = [NSJSONSerialization dataWithJSONObject:params
                                                       options:0
                                                         error:nil];
    }
    [self _sendRequest:req success:success failure:failure];
}

// ─── internal ───────────────────────────────────────────────────────────────
- (void)_sendRequest:(NSURLRequest *)req
             success:(PJSuccessBlock)success
             failure:(PJFailureBlock)failure
{
    PJConnection *conn = [[PJConnection alloc] init];
    conn.success = success;
    conn.failure = failure;

    [_activeConnections addObject:conn];

    NSURLConnection *urlConn = [[NSURLConnection alloc]
        initWithRequest:req delegate:conn startImmediately:NO];
    [urlConn scheduleInRunLoop:[NSRunLoop mainRunLoop]
                       forMode:NSRunLoopCommonModes];
    [urlConn start];

    // cleanup after finish — swizzle via notification or just let ARC/weak handle;
    // для простоты держим в массиве — connection живёт пока не отпишется
}

@end
