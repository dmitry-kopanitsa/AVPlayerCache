//
// Created by Dmitry on 24.08.15.
// Copyright (c) 2015 Home. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AVURLAssetCacheWrapper.h"
#import "ResourceLoaderDelegate.h"

@interface AVURLAssetCacheWrapper ()

@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) ResourceLoaderDelegate *resourceLoaderDelegate;

@end

@implementation AVURLAssetCacheWrapper

- (instancetype)initWithAsset:(AVURLAsset *)asset {
    self.asset = asset;
    self.resourceLoaderDelegate = [[ResourceLoaderDelegate alloc] init];
    [asset.resourceLoader setDelegate:self.resourceLoaderDelegate queue:dispatch_get_main_queue()];
    return self;
}

+ (instancetype)wrappedInstance:(AVURLAsset *)asset {
    AVURLAssetCacheWrapper *instance = [[self alloc] initWithAsset:asset];
    return instance;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *signature = [self.asset methodSignatureForSelector:sel];
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *selectorString = NSStringFromSelector([invocation selector]);
    NSLog(@"Method %@ of target %@", selectorString, self.asset);
    [invocation invokeWithTarget:self.asset];
}

@end