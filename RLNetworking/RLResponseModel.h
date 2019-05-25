//
//  RLResponseModel.h
//  RL
//
//  Created by linzuhan on 2018/8/23.
//  Copyright © 2018年 lzh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLResponseModel : NSObject

@property (nonatomic, assign) NSInteger retCode;
@property (nonatomic, copy) NSString *retMsg;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) id data;

@end
