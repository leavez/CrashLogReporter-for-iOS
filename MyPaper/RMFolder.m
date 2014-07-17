//
//  RMFolder.m
//  MyPaper
//
//  Created by Leave on 7/17/14.
//  Copyright (c) 2014 leave. All rights reserved.
//

#import "RMFolder.h"
#import "RMCrashLogMacro.h"

@interface RMFolder()
@property (nonatomic,strong) NSFileManager *fileManager;
@end

@implementation RMFolder
- (instancetype)initWithPath:(NSString *)path;
{
    self = [super init];
    if (self) {
        self.path = path;
        BOOL successed = [self createFolerAtPathIfNotExsit:path];
        if (!successed) {
            return nil;
        }
    }
    return self;
}
- (NSArray *)fileNamesInFolder;
{
    NSError *error = nil;
    NSArray* fileNames = [self.fileManager contentsOfDirectoryAtPath:self.path error:&error];
    if (error) {
        RMLog(@"could not load names in foler [%@]:%@", self.path, error.localizedDescription);
    }
    return fileNames;
}
- (void)saveDictionary:(NSDictionary *)dict withFilename:(NSString*)name;
{
    NSString *pathWithFileName = [self.path stringByAppendingPathComponent:name];
    [dict writeToFile:pathWithFileName atomically:YES];
}
- (void)saveData:(NSData*)data withFilename:(NSString*)name;
{
    NSString *pathWithFileName = [self.path stringByAppendingPathComponent:name];
    [data writeToFile:pathWithFileName atomically:YES];
}

- (NSDictionary *)loadDictionaryWithName:(NSString*)name;
{
    NSString *pathWithFileName = [self.path stringByAppendingPathComponent:name];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:pathWithFileName];
    return dict;
}
- (NSData *)loadDataWithName:(NSString*)name;
{
    NSError *error = nil;
    NSString *pathWithFileName = [self.path stringByAppendingPathComponent:name];
    NSData *data = [[NSData alloc] initWithContentsOfFile:pathWithFileName options:NSDataReadingUncached error:&error];
    if (error) {
        RMLog(@"could not load Datafile [%@]:%@", name, error.localizedDescription);
    }
    return data;
}
- (void)deleteFileNamed:(NSString *)name;
{
    NSError *error = nil;
    NSString *pathWithFileName = [self.path stringByAppendingPathComponent:name];
    [self.fileManager removeItemAtPath:pathWithFileName error:&error];
    if (error) {
        RMLog(@"could not delete file [%@]:%@", name, error.localizedDescription);
    }
}
- (void)moveFileNamed:(NSString *)name toFolder:(RMFolder *)folder;
{
    if ([folder.path isEqualToString:self.path]) {
        return;
    }
    NSError *error = nil;
    NSString *pathWithFileName = [self.path stringByAppendingPathComponent:name];
    NSString *newPathWithFileName = [folder.path stringByAppendingPathComponent:name];
    [self.fileManager moveItemAtPath:pathWithFileName toPath:newPathWithFileName error:&error];
    if (error) {
        RMLog(@"could not move file [%@]:%@", name, error.localizedDescription);
    }
}

- (BOOL)createFolerAtPathIfNotExsit:(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:@(0755) forKey:NSFilePosixPermissions];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attributes error:&error];
        if (error) {
            RMLog(@"could not Create foler [%@]:%@", self.path, error.localizedDescription);
            return NO;
        }else{
            return YES;
        }
    }
    return YES;
}

-(NSFileManager *)fileManager
{
    if (! _fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}
@end
