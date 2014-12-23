//
//  HTTPCliant.h
//  kokodoko
//
//  Created by EATis on 2013/10/28.
//  Copyright (c) 2013年 EATis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>


@interface HTTPCliant : AFHTTPSessionManager

@property (nonatomic, strong) NSString *APIKey;

+ (instancetype)sharedClient;

+ (void)setAPIKey:(NSString *)APIKey;

@end
