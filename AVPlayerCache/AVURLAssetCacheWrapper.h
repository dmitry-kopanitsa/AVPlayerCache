//
// Created by Dmitry on 24.08.15.
// Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVURLAsset;


@interface AVURLAssetCacheWrapper : NSProxy

+ (instancetype)wrappedInstance:(AVURLAsset *)asset;

@end