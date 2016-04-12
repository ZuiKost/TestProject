//
//  CZServerManager.h
//  TestTask
//
//  Created by constantine on 09.04.16.
//  Copyright © 2016 Constantine Zubovich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CZServerManager : NSObject

+ (CZServerManager *)sharedManager;

- (void)sessionsWithURLString:(NSString *)urlString
                  onSuccess:(void (^)(NSArray *sessions))success
                  onFailure:(void (^)(NSError *error))failure;


- (void)fileSizeWithURL:(NSString *)url
              onSuccess:(void (^)(NSString *fileSize))success
              onFailure:(void (^)(NSError *error))failure;


@end
