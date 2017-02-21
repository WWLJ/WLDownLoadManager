//
//  WLDownLoadResponse.h
//  WLDownLoadManager
//
//  Created by Mac on 17/2/21.
//  Copyright © 2017年 wwj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, WLDownloadStatus) {
    WLDownloadSuccuss, // 下载成功
    WLDownloadBackgroudSuccuss, // 下载成功
    WLDownloading, // 下载中
    WLDownloadFail, // 下载失败
    WLDownloadResume, // 重启
    WLDownloadCancle, // 取消
    WLDownloadPause // 暂停
};

@interface WLDownLoadResponse : NSObject


/**
 任务的唯一标识
 */
@property (nonatomic, strong) NSString *identifier;

/**
 下载状态
 */
@property (nonatomic, assign) WLDownloadStatus downloadStatus;

/**
 当前进度
 */
@property (nonatomic, assign) double progress;

/**
 之前进度
 */
@property (nonatomic, assign) double lastProgress;

/**
 下载地址
 */
@property (nonatomic, strong) NSString *downloadUrl;

/**
 存储地址
 */
@property (nonatomic, strong) NSURL *downloadSaveFileUrl;

/**
 存储数据
 */
@property (nonatomic, strong) NSData *downloadData;

/**
 下载结果,用于回调提醒
 */
@property (nonatomic, strong) NSString *downloadResult;




@end
