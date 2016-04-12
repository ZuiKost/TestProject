//
//  CZDownload.m
//  TestTask
//
//  Created by constantine on 10.04.16.
//  Copyright © 2016 Constantine Zubovich. All rights reserved.
//

#import "CZDownload.h"

@implementation CZDownload

- (instancetype)initWithURL:(NSString *)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

@end
