//
//  RMCrashLogReporter.m
//  MyPaper
//
//  Created by leave on 14-7-1.
//  Copyright (c) 2014年 leave. All rights reserved.
//



#import "RMCrashLogReporter.h"
#import <CrashReporter/PLCrashReporter.h>
#import "RMCrashLogMacro.h"

static NSString * const kExtraInfoFileName = @"extraDeviceInfo";
static NSString * const kRecordedCrashFolderName = @"recorded_crashes";
static NSString * const kCrashLogExtraInfoPostfix = @"_extraInfo";


/**
 * PLC的回调，记录一些其他的信息，比如磁盘空间，是否越狱。
 */
void recordExtraInfoCallBack(siginfo_t *info, ucontext_t *uap, void *context);

/**
 * 用来存储写其他信息的时候的文件路径。
 * 因为OC是不是async-safe，所以不能在崩溃处理时用SDK的函数生成文件路径，所以先生成。
 */
static char* extraInfoFilePath;



@implementation RMCrashLogReporter

+ (void)registerServiceWithDelegate:(id<RMCrashLogReporterConfigDataSource>)delegate;
{
    [self registerServiceWithDelegate:delegate afterDelay:1];
}


/**
 * All-in-One 初始化方法。
 * 包括：1 注册crash后的处理服务，2 检查并发送已有的crashlog
 * 这些操作不需要生成RMCrashLogRepoter的实例变量，故都是类方法。
 */

+ (void)registerServiceWithDelegate:(id<RMCrashLogReporterConfigDataSource>)delegate afterDelay:(NSTimeInterval)delay;
{
    // wait seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSAssert(delegate, @"RMCrashLogReporter delegate shouldn't be nil");
        RMConfig *config = [delegate crashLogReporterConfig];
        
        /*
         *  1 Register PLC to generate crashlog
         *    and set PLC's callback for record extra info
         *    and set some other evernment that cannot be done when crash
         */
        
        // init PLC
        PLCrashReporter *plcrashReporter = [PLCrashReporter sharedReporter];
        PLCrashReporterCallbacks crashCallbacks = {
            .version = 0,
            .context = NULL,
            .handleSignal = recordExtraInfoCallBack
        };
        [plcrashReporter setCrashCallbacks:&crashCallbacks];
        NSError *error = nil;
        BOOL success = [plcrashReporter enableCrashReporterAndReturnError:&error];
        if (!success) {
            NSLog(@"[CrashReporter] could not enable PLC:%@",error.localizedDescription);
        }
        
        // init extra info filepath
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *path = [cachePath stringByAppendingPathComponent:kExtraInfoFileName];
        extraInfoFilePath = strdup([path UTF8String]); // copy to heap
        

        
        
        /*
         *   2 Originize the info for last crash
         */
        
        // Init folder for store crashlogs
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *crashlogFolder = [cachePath stringByAppendingPathComponent: kRecordedCrashFolderName];
        if (![fileManager fileExistsAtPath:crashlogFolder]) {
            NSDictionary *attributes = [NSDictionary dictionaryWithObject:@(0755) forKey:NSFilePosixPermissions];
            [fileManager createDirectoryAtPath:crashlogFolder withIntermediateDirectories:YES attributes:attributes error:&error];
            if (error) {
                NSLog(@"[CrashReporter] could not Create foler for crashes:%@",error.localizedDescription);
            }
        }
        
        // Organize all crash info into RecordedCrash folder
        // including: 1 move crash log genereated by PLC and the extra info file into the Folder
        //            2 rename extra info file to extraInfo_******, where ***** is crashlog name.
        if ([plcrashReporter hasPendingCrashReport]) {
            NSData *protoBufData = [plcrashReporter loadPendingCrashReportDataAndReturnError:&error];
            if (protoBufData) {

                // move plc's crash
                NSString *filenameByTime = [NSString stringWithFormat: @"%.0f", [NSDate timeIntervalSinceReferenceDate]];
                filenameByTime = [crashlogFolder stringByAppendingPathComponent:filenameByTime];
                [protoBufData writeToFile:filenameByTime atomically:YES];
                
                // move extra info file into that folder
                NSString *extraInfoFileName = [filenameByTime stringByAppendingString:kCrashLogExtraInfoPostfix];
                [fileManager moveItemAtPath:path toPath:extraInfoFileName error:nil];
                
            }else{
                NSLog(@"[CrashReporter] could not load PLC crash data:%@",error.localizedDescription);
            }
        }
        
        
        
        
        /*
         *   3 Check and send to server
         */
        
        
        
    
#ifdef DEBUG
        /*
         *   4 Check after a little dalay to ensure the crash handler
         *     is not modified by others.
         *     只在debug版本中执行，为了防止其他组件（如友盟统计分析）覆盖本组件的signal的处理函数。
         *     如果signal的处理函数被更改，则本组件功能将会失效。这里只作提醒作用，如果被其他组件更改，
         *     请适量增加初始化时的延时。
         *
         *     TODO:这里未检查nsexceptionhander，只检查了signal
         */
        if (config.shouldCheckCrashHandlerNotModifiedByOthers) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
                // 获取signal handler
                struct sigaction sa_prev;
                sigaction(SIGABRT, NULL, &sa_prev);
                struct sigaction sa_plc;
                [plcrashReporter enableCrashReporter];
                sigaction(SIGABRT, NULL, &sa_plc);
                
                NSAssert(sa_plc.sa_sigaction == sa_prev.sa_sigaction, @"signal的处理函数被更改，请适量增加初始化时的延时");
            });
        }
#endif
    });
    
}

#pragma mark - inner methods


void recordExtraInfoCallBack(siginfo_t *info, ucontext_t *uap, void *context)
{
    
}



@end

@implementation RMConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        // default settings
        self.serverURL = kDefaultServerURL;
        self.bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        self.version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        self.build = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        self.shouldAutoSubmitCrashReport = NO;
        self.shouldCheckCrashHandlerNotModifiedByOthers = YES;
    }
    return self;
}
@end;