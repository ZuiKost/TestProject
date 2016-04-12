//
//  CZSession.h
//  TestTask
//
//  Created by constantine on 09.04.16.
//  Copyright © 2016 Constantine Zubovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZSession : NSObject

@property (strong, nonatomic) NSString *downloadURL;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *fileDescription;
@property (strong, nonatomic) NSString *fileSize;

@end
