//
//  RMCrashNetwork.h
//  MyPaper
//
//  Created by leave on 14-7-15.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMCrashLogReporter.h"

@interface RMCrashNetwork : NSObject
@property (nonatomic,strong) NSArray *crashFilePath;
@property (nonatomic,strong) RMConfig *config;

+ (instancetype)instanceWithCrashlogFilePathes:(NSArray*)crashPathes config:(RMConfig*)config;

- (BOOL)sendCrashes;

@end
