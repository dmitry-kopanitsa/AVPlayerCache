//
// Created by Dmitry on 24.08.15.
// Copyright (c) 2015 Home. All rights reserved.
//

#import "AVURLAsset+URLSchemeModifier.h"
#import "AVURLAssetCacheWrapper.h"


@implementation AVURLAsset (URLSchemeModifier)

+ (AVURLAsset *)cachedURLAssetWithURL:(NSURL *)URL options:(NSDictionary *)options {
    AVURLAsset *asset = [[AVURLAsset alloc] initCachedWithURL:URL options:options];
    return asset;
}

- (instancetype)initCachedWithURL:(NSURL *)URL options:(NSDictionary *)options {
    NSString *scheme = URL.scheme;
    scheme = [@"cached" stringByAppendingString:scheme];
    URL = [[NSURL alloc] initWithScheme:scheme host:URL.host path:URL.path];
    self = (AVURLAsset *)[AVURLAssetCacheWrapper wrappedInstance:[self initWithURL:URL options:options]];
    return self;
}

@end