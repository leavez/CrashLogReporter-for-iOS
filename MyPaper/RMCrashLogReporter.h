//
//  RMCrashLogReporter.h
//  MyPaper
//
//  Created by leave on 14-7-1.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDefaultServerURL @"http://10.2.45.68:8080/crash-store/crashlog/uploadCrashLog"

@class RMConfig;
@protocol RMCrashLogReporterConfigDataSource <NSObject>
@required
- (RMConfig *)crashLogReporterConfig;
@end

@interface RMCrashLogReporter : NSObject
@property (nonatomic,weak) id<RMCrashLogReporterConfigDataSource> delegate;

/**
 * All-in-One 初始化方法。
 * 包括：1 注册crash后的处理服务，2 检查并发送已有的crashlog
 * 默认延迟1s执行，以防阻碍程序启动
 */
+ (void)registerServiceWithDelegate:(id<RMCrashLogReporterConfigDataSource>)delegate;
+ (void)registerServiceWithDelegate:(id<RMCrashLogReporterConfigDataSource>)delegate afterDelay:(NSTimeInterval)delay;

@end



@interface RMConfig : NSObject

/* 
 *  Set your own server URL.
 *  default value will be use if not set
 */
@property (nonatomic, copy) NSString *serverURL;

/*
 *  Other info that will be sent to server
 *  provide more info to help developer
 *  optional.
 */
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *otherInfo;

/*
 *  Custom value for app info when send to crash log server.
 *  If they are not set manually, proper value will be use when sending.
 *  optional.
 */
@property (nonatomic, copy) NSString *bundleIdentifier;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *build;


/*
 *  Strategy
 */
@property (nonatomic, assign) BOOL shouldAutoSubmitCrashReport;
@property (nonatomic, assign) BOOL shouldCheckCrashHandlerNotModifiedByOthers; // only work in debug mode

@end
