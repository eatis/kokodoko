//
//  Post.h
//  kokodoko
//
//  Created by EATis on 2013/10/29.
//  Copyright (c) 2013年 EATis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import <MRProgress.h>
#import <MRProgress/MRProgress.h>

@class Location;

@interface Post : NSObject

- (instancetype)initWithAttributesLocation:(NSArray *)attributes;
- (instancetype)initWithAttributesAddress:(NSArray *)attributes;

@property (nonatomic, strong) NSArray *location;
@property (nonatomic, strong) NSArray *address;
@property (nonatomic, strong) NSMutableArray *locationdata;
//@property (nonatomic, strong) Location *location;


+ (NSURLSessionDataTask *)locationCode:(CLLocation *)locationCode withProgressView:(MRProgressOverlayView *)myProgressView globalTimelinePostsWithBlock:(void (^)(NSArray *posts, NSError *error))block;
@end
