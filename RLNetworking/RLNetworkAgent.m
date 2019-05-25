//
//  RLNetworkAgent.m
//  RLNetwokingDemo
//
//  Created by linzuhan on 2018/8/2.
//  Copyright © 2018年 lzh. All rights reserved.
//

#import "RLNetworkAgent.h"
#import "RLBaseRequest+Private.h"
#import <YYModel/YYModel.h>

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#import <AFNetworking/AFURLResponseSerialization.h>

#import "RLBaseRequestCommonResponseCodeProtocol.h"

@interface RLNetworkAgent ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) dispatch_queue_t processingQueue;

// 公共参数处理
@property (nonatomic, assign) BOOL isCommonResponsed;  // 是否响应过一次
@property (nonatomic, weak) id<RLBaseRequestCommonResponseCodeProtocol> commonResponse;

@end

@implementation RLNetworkAgent

+ (RLNetworkAgent *)shareAgent
{
    static RLNetworkAgent *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    
    return shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:nil];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
        
        _processingQueue = dispatch_queue_create("com.RLNetwork.networkagent.processing", DISPATCH_QUEUE_CONCURRENT);
        _manager.completionQueue = _processingQueue;
    }
    return self;
}

- (void)registerCommonResponse:(id<RLBaseRequestCommonResponseCodeProtocol>)commonResponse
{
    self.commonResponse = commonResponse;
}

- (void)resetCommonResponse
{
    self.isCommonResponsed = NO;
}

- (void)addRequest:(RLBaseRequest *)request
{
    RLRequestMethod method = [request requestMethod];
    
    NSURL *url = [request requestURL];
    NSDictionary *param = [request requestParameters];
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    if ([request isJsonRequestSerializer]) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    NSDictionary <NSString *, NSString *>*headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    
    NSString *requestMethod = @"GET";
    if (method == RLRequestMethodPost) {
        requestMethod = @"POST";
    } else if (method == RLRequestMethodPut) {
        requestMethod = @"PUT";
    }
    
    NSError *error = nil;
    NSMutableURLRequest *theRequest = nil;
    
    if (request.constructingBodyBlock) {
        theRequest = [requestSerializer multipartFormRequestWithMethod:requestMethod
                                                             URLString:url.absoluteString
                                                            parameters:param
                                             constructingBodyWithBlock:request.constructingBodyBlock
                                                                 error:&error];
    } else {
       theRequest = [requestSerializer requestWithMethod:requestMethod
                                               URLString:url.absoluteString
                                              parameters:param
                                                   error:&error];
    }

    NSLog(@"\n*******************开始网络请求*******************"\
           "\n***request url:    %@" \
           "\n***request header: \n%@" \
           "\n***request method: %@" \
           "\n***request param:  \n%@" \
           "\n*******************开始网络请求*******************" \
          ,theRequest.URL.absoluteString, theRequest.allHTTPHeaderFields,theRequest.HTTPMethod,param);

    NSURLSessionTask *task = [self.manager dataTaskWithRequest:theRequest
                                                uploadProgress:nil
                                              downloadProgress:nil
                                             completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                 NSLog(@"\n*******************结束网络请求*******************"\
                                                       "\n***response url:    %@" \
                                                       "\n***response object: \n%@" \
                                                       "\n******response error: %@" \
                                                       "\n*******************结束网络请求*******************" \
                                                       ,response.URL.absoluteString, responseObject,error);
                                                                                                  
                                                 BOOL isServerSuccess = NO;
                                                 if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
                                                     if ([response isKindOfClass:[NSHTTPURLResponse class]]
                                                         && [(NSHTTPURLResponse *)response statusCode] == 200
                                                         && responseObject
                                                         && [responseObject isKindOfClass:[NSDictionary class]]) {
                                                         isServerSuccess = YES;
                                                     }
                                                 }
                                                 
                                                 // 服务端网管拦截也参与业务逻辑处理
                                                 if (error
                                                     && [response isKindOfClass:[NSHTTPURLResponse class]]
                                                     && [(NSHTTPURLResponse *)response statusCode] == 401
                                                     && responseObject
                                                     && [responseObject isKindOfClass:[NSDictionary class]]) {
                                                     
                                                     NSNumber *retCode = [responseObject objectForKey:@"retCode"];
                                                     if ([retCode isKindOfClass:[NSNumber class]]
                                                         && retCode.integerValue < -100000) {
                                                         isServerSuccess = YES;
                                                     }
                                                 }
                                                 
                                                 if (error && !isServerSuccess) {
                                                     [self handleFailureResultWithError:error
                                                                                request:request];
                                                 } else {
                                                     [self handleSuccessResultWithResponseObject:responseObject
                                                                                         request:request];
                                                 }
                                             }];

    request.requestTask = task;
    
    [task resume];
}

- (void)cancelRequest:(RLBaseRequest *)request
{
    [request.requestTask cancel];
}

- (void)handleSuccessResultWithResponseObject:(id)responseObject
                                      request:(RLBaseRequest *)request
{
    // 赋值
    request.responseObject = responseObject;
    
    // 组装为responseModel
    request.responseModel = [RLResponseModel yy_modelWithDictionary:responseObject];
    
    [request parseDataWithData:request.responseModel.data];
    
    // 业务code
    NSInteger theCode = request.responseModel.retCode;
    NSArray *commonCodeList = nil;
    BOOL isBlockResponse = NO;
    BOOL isResponseOnce = NO;
    if (self.commonResponse && [self.commonResponse respondsToSelector:@selector(commonResponseCodeList)]) {
        commonCodeList = [self.commonResponse commonResponseCodeList];
    }
    if (self.commonResponse && [self.commonResponse respondsToSelector:@selector(isBlockResponse:)]) {
        isBlockResponse = [self.commonResponse isBlockResponse:theCode];
    }
    if (self.commonResponse && [self.commonResponse respondsToSelector:@selector(isResponseOnce:)]) {
        isResponseOnce = [self.commonResponse isResponseOnce:theCode];
    }
    
    if ([commonCodeList containsObject:@(theCode)]) {
        if (isResponseOnce) {
            [RLBaseRequest mainThread:^{
                if (!self.isCommonResponsed) {
                    self.isCommonResponsed = YES;

                    if (self.commonResponse && [self.commonResponse respondsToSelector:@selector(responseCommonCodeWithCode:request:)]) {
                        [self.commonResponse responseCommonCodeWithCode:theCode request:request];
                        
                        if (!isBlockResponse) {
                            if (request.successCompleteBlock) {
                                request.successCompleteBlock(request);
                            }
                        }
                    }
                }
            }];
        } else {
            [RLBaseRequest mainThread:^{
                if (self.commonResponse && [self.commonResponse respondsToSelector:@selector(responseCommonCodeWithCode:request:)]) {
                    [self.commonResponse responseCommonCodeWithCode:theCode request:request];
                }
                
                if (!isBlockResponse) {
                    if (request.successCompleteBlock) {
                        request.successCompleteBlock(request);
                    }
                }
            }];
        }
    } else {
        [RLBaseRequest mainThread:^{
            if (request.successCompleteBlock) {
                request.successCompleteBlock(request);
            }
        }];
    }
}

- (void)handleFailureResultWithError:(NSError *)error
                             request:(RLBaseRequest *)request
{
    // 对error做处理
    request.error = error;
    
    // 失败回调
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.failureCompleteBlock) {
            request.failureCompleteBlock(request);
        }
    });
   
}

@end
