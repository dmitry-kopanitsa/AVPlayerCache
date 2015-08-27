//
// Created by Dmitry on 25.08.15.
// Copyright (c) 2015 Home. All rights reserved.
//

#import "ResourceFileCache.h"
#import "NSString+HashFunctions.h"
#import "ResourceLoaderErrors.h"

@interface ResourceFileCache ()

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fullFilePath;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSFileHandle *writingFileHandle;
@property (nonatomic, strong) NSFileHandle *readingFileHandle;

- (void)setupFileSystemForRemotePath:(NSString *)remotePath;
+ (dispatch_queue_t)fileAccessQueue;

@end

@implementation ResourceFileCache

- (instancetype)initForRemotePath:(NSString *)remotePath {
    self = [super init];
    if (self) {
        self.remotePath = remotePath;
        [self setupFileSystemForRemotePath:remotePath];
    }
    return self;
}

- (void)saveData:(NSData *)data offset:(long long int)offset completion:(void (^)(NSError *))completion {
    dispatch_barrier_async([[self class] fileAccessQueue], ^{
        NSFileHandle *writingHandle = self.writingFileHandle;
        @try {
            [writingHandle seekToFileOffset:offset];
            [writingHandle writeData:data];
            [writingHandle synchronizeFile];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        }
        @catch (NSException *exception) {
            NSLog(@"File writing error: %@", exception);
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *error = [NSError errorWithDomain:kResourceLoaderErrorDomain
                                                         code:RLErrorFileWritingError
                                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot write data into file"}];
                    completion(error);
                });
            }
        }
    });
}

- (void)tryLoadDataWithOffset:(long long int)offset
                       length:(NSInteger)length
                      success:(void (^)(NSData *))success
                      failure:(void (^)(NSError *))failure {
    dispatch_async([[self class] fileAccessQueue], ^{
        NSFileHandle *readingHandle = self.readingFileHandle;
        @try {
            [readingHandle seekToFileOffset:offset];
            NSData *data = [readingHandle readDataOfLength:length];
            if (data) {
                if (data.length == 0) {
                    if (failure) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSError *error = [NSError errorWithDomain:kResourceLoaderErrorDomain
                                                                 code:RLErrorFileReadingZeroLengthData
                                                             userInfo:@{NSLocalizedDescriptionKey: @"Zero length data"}];
                            failure(error);
                        });
                    }
                }
                else {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success(data);
                        });
                    }
                }
            }
            else {
                if (failure) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSError *error = [NSError errorWithDomain:kResourceLoaderErrorDomain
                                                             code:RLErrorFileReadingNoData
                                                         userInfo:@{NSLocalizedDescriptionKey: @"No data"}];
                        failure(error);
                    });
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"File reading error %@", exception);
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *error = [NSError errorWithDomain:kResourceLoaderErrorDomain
                                                         code:RLErrorFileReadingFailure
                                                     userInfo:@{NSLocalizedDescriptionKey: @"File reading error"}];
                    failure(error);
                });
            }
        }
    });
}

- (void)setupFileSystemForRemotePath:(NSString *)remotePath {
    dispatch_barrier_sync([[self class] fileAccessQueue], ^{
        self.fileName = [remotePath sha512];
        NSString *fullPath = [NSString stringWithFormat:@"%@%@.tmp", NSTemporaryDirectory(), self.fileName];
        self.fullFilePath = fullPath;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        self.fileManager = fileManager;
        NSError *error;
        if (![fileManager fileExistsAtPath:fullPath]) {
            [fileManager createDirectoryAtPath:NSTemporaryDirectory()
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&error];
            if (!error) {
                [fileManager createFileAtPath:fullPath
                                     contents:nil
                                   attributes:nil];
            }
        }
        if ([fileManager fileExistsAtPath:fullPath] && !error) {
            self.writingFileHandle = [NSFileHandle fileHandleForWritingAtPath:fullPath];
            self.readingFileHandle = [NSFileHandle fileHandleForReadingAtPath:fullPath];
        }
    });
}

+ (dispatch_queue_t)fileAccessQueue {
    static dispatch_once_t once_t;
    static dispatch_queue_t queue_t;
    dispatch_once(&once_t, ^{
        queue_t = dispatch_queue_create("com.avurlassetcache.fileaccess.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue_t;
}


@end