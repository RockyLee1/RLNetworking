//
//  RLBaseRequest.h
//  RLNetwokingDemo
//
//  Created by linzuhan on 2018/8/2.
//  Copyright © 2018年 lzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLResponseModel.h"

typedef NS_ENUM(NSInteger, RLRequestMethod) {
    RLRequestMethodGet = 0,
    RLRequestMethodPost,
    RLRequestMethodPut
    
};

@class RLBaseRequest;
@protocol AFMultipartFormData;

typedef void(^RLConstructingBlock)(id<AFMultipartFormData> formData);
typedef void(^RLRequestCompleteBlock)(__kindof RLBaseRequest *request);

@interface RLBaseRequest : NSObject

@property (nonatomic, strong, readonly) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readonly) id responseObject;
@property (nonatomic, strong, readonly) RLResponseModel *responseModel;
@property (nonatomic, strong, readonly) NSError *error;

@property (nonatomic, copy) RLConstructingBlock constructingBodyBlock;

@property (nonatomic, copy) RLRequestCompleteBlock successCompleteBlock;

@property (nonatomic, copy) RLRequestCompleteBlock failureCompleteBlock;

- (void)startRequest;
- (void)stopRequest;

- (void)startRequestWithCompleteBlockWithSuccess:(RLRequestCompleteBlock)success
                                         failure:(RLRequestCompleteBlock)failure;

#pragma mark - Subclass Override

- (NSTimeInterval)requestTimeoutInterval;
- (RLRequestMethod)requestMethod;
- (NSString *)requestPath;
- (NSDictionary *)requestCustomParameters;
- (BOOL)isIgnoreUserInfoHeaderField;
- (BOOL)isJsonRequestSerializer;
- (NSDictionary <NSString *, NSString *>*)requestCommonHeaderFieldValueDictionary;
- (NSDictionary <NSString *, NSString *>*)requestCustomHeaderFieldValueDictionary;

- (void)parseDataWithData:(id)data;

#pragma mark - Helper

+ (void)mainThread:(void (^)(void))actionBlock;

@end
