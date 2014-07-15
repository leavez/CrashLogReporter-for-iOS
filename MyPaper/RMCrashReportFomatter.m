//
//  RMCrashReportFomatter.m
//  MyPaper
//
//  Created by leave on 14-7-15.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import "RMCrashReportFomatter.h"
#import <CrashReporter/PLCrashReport.h>
#import <CrashReporter/PLCrashReportTextFormatter.h>

@implementation RMCrashReportFomatter

+ (NSString *)textLogForCrashData:(NSData *)data threadNames:(NSArray *)names;
{
    NSError       *error = nil;
    PLCrashReport *report = [[PLCrashReport alloc] initWithData:data error:&error];

    if (error) {
        NSLog(@"[CrashReporter] cannot create report form protobuf data, %@", error.localizedDescription);
        return nil;
    }

    NSString *text = [PLCrashReportTextFormatter stringValueForCrashReport:report withTextFormat:PLCrashReportTextFormatiOS];

    /* add thread names to backtrace */
    NSString            *expression = @"Thread [0-9]+( Crashed)*:";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionAnchorsMatchLines error:nil];
    NSMutableString     *editLog = [NSMutableString string];
    __block int         offset = 0;
    __block int         indexForThreadNames = 0;
    NSArray             *searchResult = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    void (^addThreadNamesBlock)(NSRange range) = ^(NSRange range) {
    
        // get the substring
        NSRange  substringRange = NSMakeRange(offset, range.location - offset);
        NSString *substring = [text substringWithRange:substringRange];

        // add to mutableString
        [editLog appendString:substring];

        // add the thread name
        if ((indexForThreadNames < names.count) &&
            ![names[indexForThreadNames] isEqualToString:@""]) {
            // format like official crashlog
            [editLog appendFormat:@"Thread %d name:  %@\n", indexForThreadNames, names[indexForThreadNames]];
        }

        offset = range.location;
        indexForThreadNames++;
    };

    for (NSTextCheckingResult *result in searchResult) {
        addThreadNamesBlock(result.range);
    }

    addThreadNamesBlock(NSMakeRange(text.length, 0));

    return editLog;
}
@end
