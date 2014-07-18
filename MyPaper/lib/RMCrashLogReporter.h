//
//  RMCrashLogReporter.h
//  MyPaper
//
//  Created by leave on 14-7-1.
//  Copyright (c) 2014年 leave. All rights reserved.
//
//
//  RMCrashReporter是一个可以记录崩溃日志的服务。
//  它在程序崩溃时记录自己的崩溃日志和其他设备信息，并在下次启动时发送给服务器。
//
//  它分为两部分: 1 注册崩溃记录日志服务。
//              2 启动时检测是否有崩溃日志文件，提示用户发送。
//  其中，崩溃日志记录服务对程序正常运行逻辑和性能没有任何影响。它只注册了系统的crash handler，在崩溃的时候才会调用。
//  此功能部分（记录崩溃日志）由内嵌的PLCrashReporter实现
//
//  在连接电脑调试运行的时候，崩溃记录服务不启动。崩溃时，log窗口可以正常即使打印崩溃信息。
//  其他时候，崩溃日志记录功能启动，正常工作。
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

// if YES， 只有在wifi的情况下，才会提示是否发送log。自动发送上次发送失败的log也要等待wifi情况。
// if NO, 会把文件存在另一文件夹里，等待有新crash的时候一起发送。default value NO
@property (nonatomic, assign) BOOL onlySendInWifi;

// 在用户在提示发送时选择cancel，是否删除crash文件，如果NO，会吧crash存在另一个文件夹里
// 等待在另一个新的crash产生时一起发送
// default value is NO
@property (nonatomic, assign) BOOL shouldDeleteCrashWhenPressCancel;
@property (nonatomic, assign) BOOL shouldAutoSubmitCrashReport;
@property (nonatomic, assign) BOOL shouldCheckCrashHandlerNotModifiedByOthers; // only work in debug mode

@end
