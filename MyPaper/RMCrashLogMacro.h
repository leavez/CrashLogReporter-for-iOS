//
//  RMCrashLogMacro.h
//  MyPaper
//
//  Created by leave on 14-7-7.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#ifndef MyPaper_RMCrashLogMacro_h
#define MyPaper_RMCrashLogMacro_h

#define DELETE_CRASH_WHEN_PRESS_CANCEL_SENDING 0

static NSString * const kExtraInfoFileName = @"extraDeviceInfo";
static NSString * const kThreadInfoFileName = @"threadNamesInfo";
static NSString * const kRecordedCrashFolderName = @"recorded_crashes";
static NSString * const kSendingFailedLogFolderName = @"sending_failed_logs";

static NSString * const kCrashLogCommonPrefix = @"crashlog_";
static NSString * const kCrashLogExtraInfoPostfix = @"_extraInfo";

static NSString * const kThreadNamesKey = @"theadNames";

static NSString * const kShouldAlwaysSendingCrashKey = @"kShouldAlwaysSendingCrashKey";

static NSString * const kAlertTitle = @"发现上次程序崩溃了";
static NSString * const kAlertDetailContent = @"发送崩溃数据给我们，以便我们更好地解决问题~";

typedef void (^VoldBlockType)();

typedef enum {
    RMSendingStrategyAlways = 2,
    RMSendingStrategyOnce = 1,
    RMSendingStrategyCancel = 0
}RMSendingStrategy;

#define NON_NIL_STRING(A)   ( (A)? (A):(@"") )
#define PREFER_FORMER( A , B )    ( ((A).length > 0) ? (A): (B))

#ifdef DEBUG
#define DEBUG_ASSERT(condition, desc, ...) NSAssert(condition, desc, ...)
#else
#define DEBUG_ASSERT(condition, desc, ...) NSLog(desc)
#endif


#endif
