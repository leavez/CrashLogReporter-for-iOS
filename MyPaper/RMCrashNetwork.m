//
//  RMCrashNetwork.m
//  MyPaper
//
//  Created by leave on 14-7-15.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import "RMCrashNetwork.h"
#import "RMCrashLogMacro.h"

@interface RMCrashNetwork()
@end

@implementation RMCrashNetwork

+ (instancetype)instanceWithCrashlogFilePathes:(NSArray*)crashPathes config:(RMConfig*)config;
{
    RMCrashNetwork *instance = [[self alloc] init];
    instance.crashFilePath = crashPathes;
    instance.config = config;
    return instance;
}

//- (NSString *)jsonStringOfCrash:(NSString*)path
//{
//    // crash log data
//    NSError *error = nil;
//    NSString* filePathWithName = path;
//    NSData *logData = [[NSData alloc] initWithContentsOfFile:filePathWithName options:NSDataReadingUncached error:&error];
//    if (error) {
//        NSLog(@"[crash log] could not load crashlog file data, %@",error.localizedDescription);
//        return nil;
//    }
//    
//    // extra info dict
//    NSString *infoDictPathWithName = [filePathWithName stringByAppendingString:kCrashLogExtraInfoPostfix];
//    NSDictionary *infoDict = [[NSDictionary alloc] initWithContentsOfFile:infoDictPathWithName];
//    
//    // assemble JSON
//    
//}


@end
