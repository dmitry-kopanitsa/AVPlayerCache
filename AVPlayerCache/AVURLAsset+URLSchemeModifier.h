//
// Created by Dmitry on 24.08.15.
// Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVURLAsset (URLSchemeModifier)

+ (AVURLAsset *)cachedURLAssetWithURL:(NSURL *)URL options:(NSDictionary *)options;
- (instancetype)initCachedWithURL:(NSURL *)URL options:(NSDictionary *)options;

@end