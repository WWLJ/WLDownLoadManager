//
//  WLDownLoadGroupManager.m
//  WLDownLoadManager
//
//  Created by Mac on 17/2/21.
//  Copyright © 2017年 wwj. All rights reserved.
//

#import "WLDownLoadGroupManager.h"
#import "WLDownLoadSingleManager.h"


@interface WLDownLoadGroupManager ()

@property (nonatomic, strong) NSMutableArray *downloadManagerArr;
@property (nonatomic, copy) void(^downloadResponse)(WLDownLoadResponse *response);

@end

@implementation WLDownLoadGroupManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloadManagerArr = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}


+ (instancetype)shareGroupManager {
    static WLDownLoadGroupManager *downloadGroupManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadGroupManager = [[WLDownLoadGroupManager alloc] init];
    });
    return downloadGroupManager;
}


// 下载请求
- (void)addDownloadRequest:(NSString *)downLoadStr
                identifier:(NSString *)identifier
                targetSelf:(id)targetSelf
              showProgress:(BOOL)showProgress
      isDownloadBackground:(BOOL)isDownloadBackground
          downloadResponse:(void(^)(WLDownLoadResponse *response))downloadResponse
{
    self.downloadResponse = downloadResponse;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __weak typeof(self) this = self;
        WLDownLoadSingleManager *downloadManager = [[WLDownLoadSingleManager alloc] init];
        
        [downloadManager setDownLoadTaskInfo:downLoadStr
                       isDownloadBackground:isDownloadBackground
                                 identifier:identifier
                                    succuss:^(WLDownLoadResponse *response) {
                                        [this downloadSuccuss:response];
                                    } fail:^(WLDownLoadResponse *response) {
                                        [this downloadFail:response];
                                    } progress:^(WLDownLoadResponse *response) {
                                        if (showProgress) {
                                            self.downloadResponse(response);
                                        }
                                    } cancle:^(WLDownLoadResponse *response) {
                                        [self downloadCancle:response];
                                    } pause:^(WLDownLoadResponse *response) {
                                        [self downloadPause:response];
                                    } resume:^(WLDownLoadResponse *response) {
                                        [self downloadResume:response];
                                    }];
        [self.downloadManagerArr addObject:downloadManager];
    });

}

// 所有下载任务控制
- (void)pauseAllDownloadRequest
{
    [self.downloadManagerArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WLDownLoadSingleManager *downloadManager = (WLDownLoadSingleManager *)obj;
        [downloadManager pauseDownLoad];
    }];
}

- (void)cancleAllDownloadRequest
{
    __weak typeof(self) this = self;
    [self.downloadManagerArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WLDownLoadSingleManager *downloadManager = (WLDownLoadSingleManager *)obj;
        [downloadManager cancleDownLoad];
        
        NSString *identifier = downloadManager.identifier;
        [this removeDownloadTask:identifier];
    }];
}

- (void)resumeAllDownloadRequest
{
    [self.downloadManagerArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WLDownLoadSingleManager *downloadManager = (WLDownLoadSingleManager *)obj;
        [downloadManager resumeDownLoad];
    }];
}

// 单个下载任务控制
- (void)pauseDownload:(NSString *)identifier
{
    WLDownLoadSingleManager *downloadManager = [self getDownloadManager:identifier];
    [downloadManager pauseDownLoad];

}

- (void)resumeDownload:(NSString *)identifier
{
    WLDownLoadSingleManager *downloadManager = [self getDownloadManager:identifier];
    [downloadManager resumeDownLoad];
}

- (void)cancleDownload:(NSString *)identifier
{
    WLDownLoadSingleManager *downloadManager = [self getDownloadManager:identifier];
    [downloadManager cancleDownLoad];
    [self removeDownloadTask:identifier];
}

#pragma mark - 下载成功失败进度处理,下载基本方法，暂停、重启、取消
- (void)downloadSuccuss:(WLDownLoadResponse *)response {
    self.downloadResponse(response);
    [self removeDownloadTask:response.identifier];
}

- (void)downloadFail:(WLDownLoadResponse *)response {
    self.downloadResponse(response);
    [self removeDownloadTask:response.identifier];
}

- (void)downloadCancle:(WLDownLoadResponse *)response {
    self.downloadResponse(response);
}

- (void)downloadPause:(WLDownLoadResponse *)response {
    self.downloadResponse(response);
}

- (void)downloadResume:(WLDownLoadResponse *)response {
    self.downloadResponse(response);
}


- (WLDownLoadSingleManager *)getDownloadManager:(NSString *)identifier {
    for (NSInteger i = 0; i < self.downloadManagerArr.count; i++) {
        WLDownLoadSingleManager *downloadManager = [self.downloadManagerArr objectAtIndex:i];
        if ([downloadManager.identifier isEqualToString:identifier]) {
            return downloadManager;
        }
    }
    return nil;
}


#pragma mark - 删除下载任务
- (void)removeDownloadTask:(NSString *)identifier {
    if (!self.downloadManagerArr && self.downloadManagerArr.count == 0) {
        return;
    }
    
    __weak typeof(self) this = self;
    // 删除下载任务
    [self.downloadManagerArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *downloadManager = (NSDictionary *)obj;
        if ([downloadManager[@"identifier"] isEqualToString:identifier]) {
            [this.downloadManagerArr removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
}



@end
