//
//  WLDownLoadUtil.m
//  WLDownLoadManager
//
//  Created by Mac on 17/2/21.
//  Copyright © 2017年 wwj. All rights reserved.
//

#import "WLDownLoadUtil.h"
#import <CommonCrypto/CommonCrypto.h>


@implementation WLDownLoadUtil


+ (void)saveResumeData:(NSData *)resumeData withIdentifier:(NSString *)identifier
{
    NSString *key = [self md5EncodedStringWithString:identifier];
    NSString *resumeDataDir = [self resumeDataDir];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", resumeDataDir, key];
    [resumeData writeToFile:filePath atomically:YES];
}

+ (NSData *)getResumeDataWithIdentifier:(NSString *)identifier
{
    NSString *key = [self md5EncodedStringWithString:identifier];
    NSString *resumeDataDir = [self resumeDataDir];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", resumeDataDir, key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [[NSData alloc] initWithContentsOfFile:filePath];
    }
    return nil;
}

+ (void)removeResumeDataWithIdentifier:(NSString *)identifier
{
    NSString *key = [self md5EncodedStringWithString:identifier];
    NSString *resumeDataDir = [self resumeDataDir];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", resumeDataDir, key];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

+ (NSString *)resumeDataDir
{
    NSString *resumeDir = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory , NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"reusmeData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:resumeDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resumeDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return resumeDir;
}

+ (NSString *)successDataSavePathWithIdentifier:(NSString *)identifier
{
    
    NSString *successDir = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory , NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"successData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:successDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:successDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp4", successDir, identifier];
    
    return filePath;
}

+ (NSString *)md5EncodedStringWithString:(NSString *)string
{
    const char *cStr = [string UTF8String];
    if (NULL==cStr) {
        return @"";
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    char md5string[CC_MD5_DIGEST_LENGTH*2+1];
    
    int i;
    for(i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        sprintf(md5string+i*2, "%02x", digest[i]);
    }
    md5string[CC_MD5_DIGEST_LENGTH*2] = 0;
    
    return @(md5string);
}


+ (NSString *)filePathWithFileName:(NSString *)fileName
                        folderName:(NSString *)folderName
{
    if (fileName.length < 1) {
        return nil;
    }
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folderDirectory = cachesDirectory;
    if (folderName.length > 0) {
        folderDirectory = [NSString stringWithFormat:@"%@/%@", cachesDirectory, folderName];
    }
    BOOL isDirectory = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:folderDirectory isDirectory:&isDirectory];
    if (!(isExist && isDirectory)) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:folderDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    return [NSString stringWithFormat:@"%@/%@", folderDirectory, fileName];
}











@end
