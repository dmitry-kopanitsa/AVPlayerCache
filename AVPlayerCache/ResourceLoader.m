//
// Created by Dmitry on 25.08.15.
// Copyright (c) 2015 Home. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ResourceLoader.h"
#import "ResourceFileCache.h"
#import "ResourceLoaderErrors.h"

@interface ResourceLoader () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) AVAssetResourceLoadingRequest *request;
@property (nonatomic, strong) ResourceFileCache *fileCache;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

- (void)loadResourceFromOffset:(long long int)offset length:(NSInteger)length;
@end

@implementation ResourceLoader

+ (ResourceLoader *)loaderWithRequest:(AVAssetResourceLoadingRequest *)request {
    ResourceLoader *loader = [[self alloc] initWithRequest:request];
    return loader;
}

- (instancetype)initWithRequest:(AVAssetResourceLoadingRequest *)request {
    self = [super init];
    if (self) {
        self.request = request;
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.fileCache = [[ResourceFileCache alloc] initForRemotePath:request.request.URL.absoluteString];
        [self loadResourceFromOffset:request.dataRequest.requestedOffset length:request.dataRequest.requestedLength];
    }
    return self;
}

- (void)loadResourceFromOffset:(long long int)offset length:(NSInteger)length {
    __weak ResourceLoader *weakSelf = self;
    void (^dataLoaded)(NSData *, NSURLResponse *) = ^(NSData *data, NSURLResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"data %@ data, class %@\n response %@", data, [data class], response);
            weakSelf.request.response = response;
            [weakSelf.request.dataRequest respondWithData:data];
            [weakSelf.request finishLoading];
        });
    };
    void (^networkDataLoaded)(NSData *, NSURLResponse *) = ^(NSData *data, NSURLResponse *response) {
        [weakSelf.fileCache saveData:data offset:offset completion:^(NSError *error) {
        }];
        dataLoaded(data, response);
    };
    void (^loadingFailure)(NSError *) = ^(NSError *error) {
        [weakSelf.request finishLoadingWithError:error];
    };
    void (^fileDataLoaded)(NSData *) = ^(NSData *data) {
        dataLoaded(data, nil);
    };
    void (^fileDataLoadingFailure)(NSError *) = ^(NSError *error) {
        [weakSelf downloadDataFromOffset:offset length:length success:networkDataLoaded failure:loadingFailure];
    };
    [self.fileCache tryLoadDataWithOffset:offset length:length success:fileDataLoaded failure:fileDataLoadingFailure];
}

- (void)downloadDataFromOffset:(long long int)offset
                        length:(NSInteger)length
                       success:(void (^)(NSData *, NSURLResponse *))success
                       failure:(void (^)(NSError *))failure {
    // TODO: download data
    NSURL *url = self.request.request.URL;
    NSString *scheme = url.scheme;
    if ([scheme isEqualToString:@"cachedhttp"]) {
        scheme = @"http";
    }
    else if ([scheme isEqualToString:@"cachedhttps"]) {
        scheme = @"https";
    }
    else {
        NSError *error = [NSError errorWithDomain:kResourceLoaderErrorDomain
                                             code:RLErrorWrongURLScheme
                                         userInfo:@{NSLocalizedDescriptionKey: @"Wrong URL scheme"}];
        if (failure) {
            failure(error);
        }
        return;
    }
    url = [[NSURL alloc] initWithScheme:scheme host:url.host path:url.path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setValue:[NSString stringWithFormat:@"bytes=%lld-%lld", offset, (offset+length-1)] forHTTPHeaderField:@"Range"];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:self.operationQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                if (connectionError) {
                                    if (failure) {
                                        failure(connectionError);
                                    }
                                }
                                else {
                                    if (success) {
                                        success(data, response);
                                    }
                                }
                           }];
}

- (void)cancel {
    NSError *error = [NSError errorWithDomain:kResourceLoaderErrorDomain
                                         code:RLErrorCancel
                                     userInfo:@{NSLocalizedDescriptionKey: @"Loading was cancelled"}];
    [self.request finishLoadingWithError:error];
    self.request = nil;
}

@end