//
//  RMViewController.m
//  MyPaper
//
//  Created by leave on 14-7-1.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import "RMViewController.h"

@interface RMViewController ()

@end

@implementation RMViewController
char* stringFromUnsignedInt(unsigned value);

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
// NSURL *path = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]; // 必须是 没有file://这样的开头
    path = [NSString stringWithFormat:@"%@/gao.txt",path];

    const char* storePath = [path UTF8String];
    writeByte(storePath, "gao1.txt", "ff");
//    writeFloat(storePath, "gao.txt", 1.222222);


    char *a = stringFromUnsignedInt(123456);
    NSLog(@"%s",a);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


char* stringFromUnsignedInt(unsigned value)
{
    if (value == 0) {
        return "0";
    }
    char *string = (char *)malloc(sizeof(char)*32);
    int index = 0;
    while ( value > 0 ) {
        if (index < 32 - 1) { // to avoid stackoverflow, -1是为了\0预留
            int prime = (int)(value % 10);
            value = (int)(value/10);
            string[index] = '0'+ prime; // covert int 0-9 to string, use ASIC
            index++;
        }else{
            return ""; // error
        }
    }
    
    // reverse the string
    for (int i = 0; i < (int)(index / 2); i++) {
        int m = string[i];
        string[i] = string[index - 1 - i];
        string[index - 1 - i] = m;
    }
    
    // add the end symbol
    string[index] = '\0';
    
    return string;
}


#import <errno.h>
#import <unistd.h>
#import <fcntl.h>
#import <string.h>

ssize_t writeByte_inner (int fd, const void *data, size_t len);


size_t writeByte (const char* pathWithFilename ,const char* propertyName, const void* data)
{
    //write file
    int fd = open(pathWithFilename, O_WRONLY|O_CREAT|O_APPEND, 0644);
    int writtenBytes = 0;
    
    const void* dataArrayToWrite[] = {propertyName, ":", data, "\n"};
    for(int i=0 ; i<4 ;i++){
        int partBytes = writeByte_inner(fd, dataArrayToWrite[i], strlen(dataArrayToWrite[i]));
        if (partBytes != -1) {
            writtenBytes += partBytes;
        }else{
            return -1;
        }
    }
    return writtenBytes;
}


ssize_t writeByte_inner (int fd, const void *data, size_t len)
{
    //copy the code from PLC, plcrash_async_writen
    const void *p;
    size_t left;
    ssize_t written = 0;
    
    /* Loop until all bytes are written */
    p = data;
    left = len;
    while (left > 0) {
        if ((written = write(fd, p, left)) <= 0) {
            if (errno == EINTR) {
                // Try again
                written = 0;
            } else {
                return -1;
            }
        }
        
        left -= written;
        p += written;
    }
    
    return written;
}

size_t writeUnsignInt(const char* path ,const char* fileName, unsigned int value )
{
    char *string = stringFromUnsignedInt(value);
    return writeByte(path, fileName, string);
}


@end
