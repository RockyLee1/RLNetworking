//
//  RLBaseRequest.m
//  RLNetwokingDemo
//
//  Created by linzuhan on 2018/8/2.
//  Copyright © 2018年 lzh. All rights reserved.
//

#import "RLBaseRequest.h"
#import "RLNetworkAgent.h"

@interface RLBaseRequest ()

@property (nonatomic, strong, readwrite) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readwrite) id responseObject;
@property (nonatomic, strong, readwrite) RLResponseModel *responseModel;
@property (nonatomic, strong, readwrite) NSError *error;

@end

@implementation RLBaseRequest

- (void)dealloc
{
    NSLog(@"%@ has dealloc",[self class]);
}

#pragma mark - Subclass Override

- (NSTimeInterval)requestTimeoutInterval
{
    return 30;
}

- (RLRequestMethod)requestMethod
{
    // default is GET
    return RLRequestMethodGet;
}

- (NSURL *)requestURL
{
    NSString *baseURLString = [self baseURLString];
    NSString *requestPath = [self requestPath];
    
    return [NSURL URLWithString:[baseURLString stringByAppendingString:requestPath]];
}

- (NSString *)baseURLString
{
    return @"";
}

- (NSString *)requestPath
{
    return @"";
}

#pragma mark - Request Header

- (NSDictionary <NSString *, NSString *>*)requestHeaderFieldValueDictionary
{
    NSDictionary *dic1 = [self requestCommonHeaderFieldValueDictionary];
    NSDictionary *dic2 = [self requestCustomHeaderFieldValueDictionary];
    
    if (dic1 == nil && dic2 == nil) {
        return nil;
    }
    
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
    if (dic1 && [dic1 isKindOfClass:[NSDictionary class]]) {
        [tmpDic addEntriesFromDictionary:dic1];
    }
    
    if (dic2 && [dic2 isKindOfClass:[NSDictionary class]]) {
        [tmpDic addEntriesFromDictionary:dic2];
    }

    return [tmpDic copy];
}

- (BOOL)isIgnoreUserInfoHeaderField
{
    return NO;
}

- (BOOL)isJsonRequestSerializer
{
    return NO;
}

- (NSDictionary <NSString *, NSString *>*)requestCommonHeaderFieldValueDictionary
{
    return nil;
}

- (NSDictionary <NSString *, NSString *>*)requestCustomHeaderFieldValueDictionary
{
    return nil;
}


#pragma mark - Request Param

- (NSDictionary *)requestParameters
{
    NSDictionary *dic1 = [self requestCommonParameters];
    NSDictionary *dic2 = [self requestCustomParameters];
    
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
    if (dic1 && [dic1 isKindOfClass:[NSDictionary class]]) {
        [tmpDic addEntriesFromDictionary:dic1];
    }
    
    if (dic2 && [dic2 isKindOfClass:[NSDictionary class]]) {
        [tmpDic addEntriesFromDictionary:dic2];
    }
    
    return [tmpDic copy];
}

- (NSDictionary *)requestCustomParameters
{
    return nil;
}

- (NSDictionary *)requestCommonParameters
{
    return nil;
}

#pragma mark - Parse Response

- (void)parseDataWithData:(id)data
{
    // do nothing
}

#pragma mark - Request Action Method

- (void)startRequest
{
    [[RLNetworkAgent shareAgent] addRequest:self];
}

- (void)stopRequest
{
    [[RLNetworkAgent shareAgent] cancelRequest:self];
}

- (void)startRequestWithCompleteBlockWithSuccess:(RLRequestCompleteBlock)success
                                         failure:(RLRequestCompleteBlock)failure
{
    self.successCompleteBlock = success;
    self.failureCompleteBlock = failure;
    
    [self startRequest];
}

#pragma mark - Helper

+ (void)mainThread:(void (^)(void))actionBlock
{
    if ([[NSThread currentThread] isMainThread]) {
        if (actionBlock) {
            actionBlock();
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (actionBlock) {
                actionBlock();
            }
        });
    }
}

@end
