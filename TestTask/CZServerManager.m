//
//  CZServerManager.m
//  TestTask
//
//  Created by constantine on 09.04.16.
//  Copyright © 2016 Constantine Zubovich. All rights reserved.
//

#import "CZServerManager.h"
#import <AFNetworking.h>
#import "CZParser.h"
#import "CZSession.h"

@interface CZServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager *requestManager;

@end

@implementation CZServerManager

+ (CZServerManager *)sharedManager {
    
    static CZServerManager *serverManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serverManager = [[CZServerManager alloc] init];
    });
    
    return serverManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestManager = [AFHTTPSessionManager manager];
    }
    return self;
}

- (void)sessionsWithURLString:(NSString *)urlString
                  onSuccess:(void (^)(NSArray *sessions))success
                  onFailure:(void (^)(NSError *error))failure {

    self.requestManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [self.requestManager GET:urlString
                  parameters:nil
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         CZParser *parser = [[CZParser alloc] init];
                         
                         NSArray *array = [parser dataFromSessions:[responseObject objectForKey:@"sessions"]];
                         
                         if (success) {
                             success(array);
                         }
                         
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         if (failure) {
                             failure(error);
                         }
                     }];
    
}

- (void)fileSizeWithURL:(NSString *)url
                    onSuccess:(void (^)(NSString *fileSize))success
                    onFailure:(void (^)(NSError *error))failure {
    
    [self.requestManager HEAD:url
                   parameters:nil
                      success:^(NSURLSessionDataTask * _Nonnull task) {
                          
                          NSString *totalSize = [NSByteCountFormatter stringFromByteCount:task.countOfBytesExpectedToReceive countStyle:NSByteCountFormatterCountStyleBinary];
                          
                          if (success) {
                              success(totalSize);
                          }
                          
                      }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          
                          
                          
                      }];
}

@end
