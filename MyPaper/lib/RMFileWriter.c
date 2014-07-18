//
//  RHCWriteCAPI.c
//  writeCDemo
//
//  Created by leave on 14-1-10.
//  Copyright (c) 2014年 leave. All rights reserved.
//


#include <stdio.h>
#import "RMFileWriter.h"
#import <errno.h>
#import <unistd.h>
#import <fcntl.h>

size_t stringLength(const char* string);
ssize_t writeByte_inner (int fd, const void *data, size_t len);


ssize_t writeByte (const char* pathWithFilename ,const char* propertyName, const char* data)
{
    //write file
    int fd = open(pathWithFilename, O_WRONLY|O_CREAT|O_APPEND, 0644);
    int writtenBytes = 0;
    
    const char* dataArrayToWrite[] = {propertyName, ":", data, "\n"};
    for(int i=0 ; i<4 ;i++){
        ssize_t partBytes = writeByte_inner(fd, dataArrayToWrite[i], stringLength(dataArrayToWrite[i]));
        if (partBytes != -1) {
            writtenBytes += partBytes;
        }else{
            return -1;
        }
    }
    close(fd);
    return writtenBytes;
}

ssize_t writeThreadNames (const char* pathWithFilename, thread_name_array_t names)
{
    int fd = open(pathWithFilename, O_WRONLY|O_CREAT, 0644);
    int writtenBytes = 0;
    for(int i=0 ; i < names.count ;i++){
        ssize_t partBytes = writeByte_inner(fd, names.all_names_array[i], stringLength(names.all_names_array[i]));
        if (partBytes != -1) {
            writtenBytes += partBytes;
        }else{
            return -1;
        }
        partBytes = writeByte_inner(fd, "\n", stringLength("\n"));
        if (partBytes != -1) {
            writtenBytes += partBytes;
        }else{
            return -1;
        }
    }
    close(fd);
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

ssize_t writeUnsignInt(const char* pathWithFilename ,const char* propertyName, unsigned int value)
{
    // convet int to string
    char string_buf[32] = "0";
    
    if (value != 0) {
        int error = 0;
        int index = 0;
        while ( value > 0 ) {
            if (index < 32 - 1) { // to avoid stackoverflow, -1是为了\0预留
                int prime = (int)(value % 10);
                value = (int)(value/10);
                string_buf[index] = '0'+ prime; // covert int 0-9 to string, use ASIC
                index++;
            }else{
                // error : overflow
                string_buf[0] = '\0';
                error = 1;
                break;
            }
        }
        
        // reverse the string
        if (error != 1) {
            for (int i = 0; i < (int)(index / 2); i++) {
                int m = string_buf[i];
                string_buf[i] = string_buf[index - 1 - i];
                string_buf[index - 1 - i] = m;
            }
            // add the end symbol
            string_buf[index] = '\0';
        }
    }
    
    return writeByte(pathWithFilename, propertyName, string_buf);
}

// async-safe
size_t stringLength(const char *string)
{
    int index = 0;
    while ( *string != '\0'){
        index++;
        string++;
    }
    return index;
}
