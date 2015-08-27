//
// Created by Dmitry on 25.08.15.
// Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ResourceLoader : NSObject

+ (ResourceLoader *)loaderWithRequest:(AVAssetResourceLoadingRequest *)request;
- (instancetype)initWithRequest:(AVAssetResourceLoadingRequest *)request;
- (void)cancel;
- (void)downloadDataFromOffset:(long long int)offset
                        length:(NSInteger)length
                       success:(void (^)(NSData *, NSURLResponse *))success
                       failure:(void (^)(NSError *))failure;
@end