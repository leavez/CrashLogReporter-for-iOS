//
//  RMCrashNetwork.m
//  MyPaper
//
//  Created by leave on 14-7-15.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import "RMCrashNetwork.h"
#import "RMCrashLogMacro.h"
#import "RMCrashReportFomatter.h"
#include <sys/sysctl.h>

@interface RMCrashNetwork()
@end

@implementation RMCrashNetwork

//static RMCrashNetwork* sharedInstance = nil;
//
//+ (instancetype)sharedInstance
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedInstance = [[self alloc] init];
//    });
//    return sharedInstance;
//}

- (void)sendCrashes;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        for (NSString *name in self.crashNames) {
            RMCrashFile* crash = [self.folder loadCrashWithTimedName:name];
            NSDictionary *postedDict = [self assemblePostedDictionayWithLog:crash.logData extraInfoDict:crash.extraInfo];
            NSData *data = [self postedBodyData:postedDict];
            BOOL successed = [self postJsonData:data]; // synchronous method, block thread
            if (self.completionBlockForEveryCrash) {
                self.completionBlockForEveryCrash(successed,name);
            }
        }
        
    });
}

- (NSDictionary *)assemblePostedDictionayWithLog:(NSData *)logData extraInfoDict:(NSDictionary *)infoDict
{
    // 1 get the text verison crash log
    NSString *log = [RMCrashReportFomatter textLogForCrashData:logData threadNames:infoDict[kThreadNamesKey]];

    // 2 assemble all info to send into one dict
    NSString *bundleIdentifier = PREFER_FORMER(self.config.bundleIdentifier, [[NSBundle mainBundle] bundleIdentifier]);
    NSString *build = PREFER_FORMER(self.config.build, [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]);
    NSString *version = PREFER_FORMER(self.config.version, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]);
    NSString *binaryName = [[NSString alloc] initWithUTF8String:[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"] UTF8String]];
    NSString *systemVersion = NON_NIL_STRING([[UIDevice currentDevice] systemVersion]);
    NSString *platform      = NON_NIL_STRING([self getDevicePlatform]);
    NSString *jailbreak     = NON_NIL_STRING(infoDict[@"jailbreak"]);
    NSString *freeRAM       = NON_NIL_STRING(infoDict[@"freeRam"]);
    NSString *occupiedRAM   = NON_NIL_STRING(infoDict[@"usedRam"]);
    NSString *freeSpace     = NON_NIL_STRING(infoDict[@"freeDisk"]);
    NSString *cpuUsage      = NON_NIL_STRING(infoDict[@"cpuUsage"]);
    NSString *userid        = NON_NIL_STRING(self.config.userID);
    NSString *otherInfo     = NON_NIL_STRING(self.config.otherInfo);

    NSDictionary *finalDict = @{@"bundle_identifier":bundleIdentifier,
                                @"version":version,
                                @"build":build,
                                @"app_name":binaryName,
                                @"system_version":systemVersion,
                                @"platform":platform,
                                @"crashlog":log,
                                @"jailbreak":jailbreak,
                                @"free_ram":freeRAM,
                                @"occupied_ram":occupiedRAM,
                                @"free_space":freeSpace,
                                @"cpu_usage":cpuUsage,
                                @"user_id":userid,
                                @"develop_description":otherInfo,
                                @"proximity":@"0", // 不用了
                                @"battery":@"0"};
    return finalDict;
}
#pragma mark - HTTP Request

// synchronous method, block thread
- (BOOL)postJsonData:(NSData*)jsonData
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.config.serverURL]];
    [request setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%@, en-us", [[NSLocale preferredLanguages] componentsJoinedByString:@", "] ] forHTTPHeaderField:@"Accept-Language"];
    [request setHTTPBody:jsonData];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSUInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    if (statusCode >= 200 && statusCode < 400) {
        return NO;
    }else{
        NSDictionary *parsedJson = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        int errorCode = [parsedJson[@"error_code"] integerValue];
        if (errorCode == 0) {
            return YES;
        }else{
            NSString *errorMsg = parsedJson[@"error_msg"];
            NSLog(@"[crash log] sending Failed: %@",errorMsg);
            return NO;
        }
    }
}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//        self.statusCode = [(NSHTTPURLResponse *)response statusCode];
//    }
//}
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    if (self.statusCode >= 200 && self.statusCode < 400) {
//        // success
//        // remove file
//        [[NSFileManager defaultManager] removeItemAtPath:self.sendingCrashPath error:nil];
//    }else{
//        // failed
//    }
//}

#pragma mark - HTTP Body Data

- (NSData*)postedBodyData:(NSDictionary *)fieldsToBePosted
{
//    return [NSJSONSerialization dataWithJSONObject:fieldsToBePosted options:NSJSONWritingPrettyPrinted error:nil];
    return [[self urlEncodedKeyValueString:fieldsToBePosted] dataUsingEncoding:NSUTF8StringEncoding];
}

// code copied from MKNetwork lib
- (NSString *)urlEncodedKeyValueString:(NSDictionary *)dict
{
    NSMutableString *string = [NSMutableString string];

    for (NSString *key in dict) {
        id value = [dict valueForKey:key];

        if ([value isKindOfClass:[NSString class]]) {
            [string appendFormat:@"%@=%@&", [self urlEncodedString:key], [self urlEncodedString:((NSString *)value)]];
        } else {
            [string appendFormat:@"%@=%@&", [self urlEncodedString:key], value];
        }
    }

    if ([string length] > 0) {
        [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
    }

    return string;
}

// code copied from MKNetwork lib
- (NSString *)urlEncodedString:(NSString *)inputString
{
    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault,
            (__bridge CFStringRef)inputString,
            nil,
            CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
            kCFStringEncodingUTF8);

    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString *)encodedCFString];

    if (!encodedString) {
        encodedString = @"";
    }

    return encodedString;
}


#pragma mark - tool

- (NSString *)getDevicePlatform {
    size_t size = 0;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *answer = (char*)malloc(size);
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    free(answer);
    return platform;
}
@end
