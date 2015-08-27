//
// Created by Dmitry on 25.08.15.
// Copyright (c) 2015 Home. All rights reserved.
//

#import "ResourceLoaderDelegate.h"
#import "ResourceLoader.h"

@interface ResourceLoaderDelegate ()

@property (nonatomic, strong) ResourceLoader *loader;

@end

@implementation ResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"wait request %@", loadingRequest);
    BOOL shouldWait = NO;
    NSString *urlString = loadingRequest.request.URL.scheme;
    if ([urlString isEqualToString:@"cachedhttp"] || [urlString isEqualToString:@"cachedhttps"]) {
        ResourceLoader *loader = [ResourceLoader loaderWithRequest:loadingRequest];
        self.loader = loader;
        shouldWait = YES;
    }
    return shouldWait;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"cancel request %@", loadingRequest);
    [self.loader cancel];
    self.loader = nil;
}

@end