//
//  CZDownload.h
//  TestTask
//
//  Created by constantine on 10.04.16.
//  Copyright © 2016 Constantine Zubovich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CZDownload : NSObject

@property (strong, nonatomic) NSString *url;
@property (assign, nonatomic) BOOL isDownloading;
@property (assign, nonatomic) CGFloat progress;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic) NSData *resumeData;

- (instancetype)initWithURL:(NSString *)url;

@end
