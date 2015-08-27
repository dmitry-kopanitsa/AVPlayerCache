//
// Created by Dmitry on 25.08.15.
// Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ResourceFileCache : NSObject

@property (nonatomic, strong) NSString *remotePath;

- (instancetype)initForRemotePath:(NSString *)remotePath;
- (void)saveData:(NSData *)data offset:(long long int)offset completion:(void (^)(NSError *))completion;
- (void)tryLoadDataWithOffset:(long long int)offset
                       length:(NSInteger)length
                      success:(void (^)(NSData *))success
                      failure:(void (^)(NSError *))failure;

@end