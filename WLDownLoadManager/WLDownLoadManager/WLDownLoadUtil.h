//
//  WLDownLoadUtil.h
//  WLDownLoadManager
//
//  Created by Mac on 17/2/21.
//  Copyright © 2017年 wwj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLDownLoadUtil : NSObject


/**
 存储临时数据

 @param resumeData <#resumeData description#>
 @param identifier identifier
 */
+ (void)saveResumeData:(NSData *)resumeData withIdentifier:(NSString *)identifier;



/**
 获取临时数据

 @param identifier identifier
 @return <#return value description#>
 */
+ (NSData *)getResumeDataWithIdentifier:(NSString *)identifier;



/**
 删除临时数据

 @param identifier identifier
 */
+ (void)removeResumeDataWithIdentifier:(NSString *)identifier;


/**
 临时数据缓冲文件夹

 @return <#return value description#>
 */
+ (NSString *)resumeDataDir;



/**
 MD5加密

 @param string <#string description#>
 @return <#return value description#>
 */
+ (NSString *)md5EncodedStringWithString:(NSString *)string;






/**
 下载成功存储路径

 @param identifier <#identifier description#>
 @return <#return value description#>
 */
+ (NSString *)successDataSavePathWithIdentifier:(NSString *)identifier;






@end
