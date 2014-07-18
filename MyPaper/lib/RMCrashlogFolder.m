//
//  RMCrashlogFolder.m
//  MyPaper
//
//  Created by Leave on 7/17/14.
//  Copyright (c) 2014 leave. All rights reserved.
//

#import "RMCrashlogFolder.h"
#import "RMCrashLogMacro.h"

@implementation RMCrashFile
@end

@implementation RMCrashlogFolder

- (BOOL)haveCrashlogs;
{
    return [self crashNamesInFolder].count > 0;
}
- (NSArray *)crashNamesInFolder;
{
    NSArray *allFiles = [super fileNamesInFolder];
    NSMutableArray *validCrashFileNames = [NSMutableArray array];
    for (NSString *filename in allFiles) {
        if ([filename hasPrefix:kCrashLogCommonPrefix] &&
            ![filename hasSuffix:kCrashLogExtraInfoPostfix]) {
            NSString *strippedName = [filename substringFromIndex:kCrashLogCommonPrefix.length];
            [validCrashFileNames addObject:strippedName];
        }
    }
    return validCrashFileNames;
}

- (void)saveCrashFile:(RMCrashFile *)crash withTimedName:(NSString*)name;
{
    NSString *logName = [kCrashLogCommonPrefix stringByAppendingString:name];
    NSString *infoName = [logName stringByAppendingString:kCrashLogExtraInfoPostfix];
    [super saveData:crash.logData withFilename:logName];
    [super saveDictionary:crash.extraInfo withFilename:infoName];
}

- (RMCrashFile *)loadCrashWithTimedName:(NSString*)name;
{
    RMCrashFile *file = [RMCrashFile new];
    NSString *logName = [kCrashLogCommonPrefix stringByAppendingString:name];
    NSString *infoName = [logName stringByAppendingString:kCrashLogExtraInfoPostfix];
    file.logData = [super loadDataWithName:logName];
    file.extraInfo = [super loadDictionaryWithName:infoName];
    return file;
}
- (void)removeCrashNamed:(NSString *)name;
{
    NSString *logName = [kCrashLogCommonPrefix stringByAppendingString:name];
    NSString *infoName = [logName stringByAppendingString:kCrashLogExtraInfoPostfix];
    [super deleteFileNamed:logName];
    [super deleteFileNamed:infoName];
}

- (void)moveCrashNamed:(NSString *)name toFolder:(RMFolder *)folder;
{
    NSString *logName = [kCrashLogCommonPrefix stringByAppendingString:name];
    NSString *infoName = [logName stringByAppendingString:kCrashLogExtraInfoPostfix];
    [super moveFileNamed:logName toFolder:folder];
    [super moveFileNamed:infoName toFolder:folder];
}
- (RMCrashlogFolder *)createSubfolder:(NSString *)name;
{
    NSString *newPath = [self.path stringByAppendingPathComponent:name];
    RMCrashlogFolder *subfolder = [[RMCrashlogFolder alloc] initWithPath:newPath];
    return subfolder;
}

@end
