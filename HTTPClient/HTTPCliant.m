//
//  HTTPCliant.m
//  kokodoko
//
//  Created by EATis on 2013/10/28.
//  Copyright (c) 2013年 EATis. All rights reserved.
//

#import "HTTPCliant.h"
#import <AFNetworking/AFURLRequestSerialization.h>

#import <CoreLocation/CoreLocation.h>


//#define API_BASE_URL      @"http://api.crunchbase.com/v/1/"
static NSString * const YahooAPIBaseURLString = @"http://reverse.search.olp.yahooapis.jp";

@interface HTTPCliant()
//@property (nonatomic, strong) NSString *APIKey;
@end

@implementation HTTPCliant

+ (instancetype)sharedClient {
    static HTTPCliant *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HTTPCliant alloc] initWithBaseURL:[NSURL URLWithString:YahooAPIBaseURLString]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
    });
    
    return _sharedClient;
}

#pragma mark - Public

+ (void)setAPIKey:(NSString *)APIKey {
    
    [[HTTPCliant sharedClient] setAPIKey:APIKey];
}



@end
