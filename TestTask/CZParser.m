//
//  CZParser.m
//  TestTask
//
//  Created by constantine on 09.04.16.
//  Copyright © 2016 Constantine Zubovich. All rights reserved.
//

#import "CZParser.h"
#import "CZSession.h"

@implementation CZParser

- (NSArray *)dataFromSessions:(NSArray *)sessions {
    
    NSMutableArray *sessionsArray = [NSMutableArray array];
    
    for (NSDictionary *dictionary in sessions) {
        
        CZSession *session = [[CZSession alloc] init];
        session.downloadURL = [dictionary objectForKey:@"download_sd"];
        session.title = [dictionary objectForKey:@"title"];
        session.fileDescription = [dictionary objectForKey:@"description"];
        
        [sessionsArray addObject:session];
    }
    
    return sessionsArray;
}

@end
