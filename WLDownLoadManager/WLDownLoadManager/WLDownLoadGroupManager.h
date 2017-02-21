//
//  WLDownLoadGroupManager.h
//  WLDownLoadManager
//
//  Created by Mac on 17/2/21.
//  Copyright © 2017年 wwj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLDownLoadResponse.h"

@interface WLDownLoadGroupManager : NSObject

typedef void(^downloadResponse)(WLDownLoadResponse *response);

+ (id)shareGroupManager;

// 下载请求
/**
 添加一个下载请求

 @param downLoadStr 下载地址
 @param identifier 唯一标识
 @param targetSelf 执行者
 @param showProgress 是否显示进度
 @param isDownloadBackground 是否后台下载
 @param downloadResponse <#downloadResponse description#>
 */
- (void)addDownloadRequest:(NSString *)downLoadStr
                identifier:(NSString *)identifier
                targetSelf:(id)targetSelf
              showProgress:(BOOL)showProgress
      isDownloadBackground:(BOOL)isDownloadBackground
          downloadResponse:(void(^)(WLDownLoadResponse *response))downloadResponse;

// 所有下载任务控制
- (void)pauseAllDownloadRequest;
- (void)cancleAllDownloadRequest;
- (void)resumeAllDownloadRequest;

// 单个下载任务控制
- (void)pauseDownload:(NSString *)identifier;
- (void)resumeDownload:(NSString *)identifier;
- (void)cancleDownload:(NSString *)identifier;



@end
