//
//  RMCrashNetwork.h
//  MyPaper
//
//  Created by leave on 14-7-15.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMCrashLogReporter.h"
#import "RMCrashlogFolder.h"

@interface RMCrashNetwork : NSObject
@property (nonatomic,strong) RMCrashlogFolder *folder;
@property (nonatomic,strong) NSArray *crashNames;
@property (nonatomic,strong) RMConfig *config;
@property (nonatomic,copy) void (^completionBlockForEveryCrash)(BOOL successed, NSString *name);

// Synchronous method run in background thread
- (void)sendCrashes;

@end
