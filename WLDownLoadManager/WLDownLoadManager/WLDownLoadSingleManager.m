//
//  WLDownLoadSingleManager.m
//  WLDownLoadManager
//
//  Created by Mac on 17/2/21.
//  Copyright © 2017年 wwj. All rights reserved.
//

#import "WLDownLoadSingleManager.h"
#import "WLDownLoadUtil.h"
#import "AppDelegate.h"


@interface WLDownLoadSingleManager ()<NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSURLSessionDownloadTask *backgroundSessionTask;

@property (nonatomic, strong) NSURLSession *normalSession;
@property (nonatomic, strong) NSURLSessionDownloadTask *normalSessionTask;

@property (nonatomic, strong) NSData *partialData;
@property (nonatomic, copy) void(^downloadSuccuss)(WLDownLoadResponse *response);
@property (nonatomic, copy) void(^downloadFail)(WLDownLoadResponse *response);
@property (nonatomic, copy) void(^downloadProgress)(WLDownLoadResponse *response);
@property (nonatomic, copy) void(^downloadCancle)(WLDownLoadResponse *response);
@property (nonatomic, copy) void(^downloadPause)(WLDownLoadResponse *response);
@property (nonatomic, copy) void(^downloadResume)(WLDownLoadResponse *response);
@property (nonatomic, assign) double lastProgress;
@property (nonatomic, strong) WLDownLoadResponse *downloadResponse;

@end


@implementation WLDownLoadSingleManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundSession.sessionDescription = @"com.yourcompany.appId.BackgroundSession";
    }
    return self;
}


#pragma mark  --------
#pragma mark  设置任务的信息
- (void)setDownLoadTaskInfo:(NSString *) downLoadUrl
       isDownloadBackground:(BOOL)isDownLoadBackground
                 identifier:(NSString *)identifier
                    succuss:(void (^)(WLDownLoadResponse *response)) succuss
                       fail:(void(^)(WLDownLoadResponse *response)) fail
                   progress:(void(^)(WLDownLoadResponse *response)) progress
                     cancle:(void(^)(WLDownLoadResponse *response)) cancle
                      pause:(void(^)(WLDownLoadResponse *response)) pause
                     resume:(void(^)(WLDownLoadResponse *response)) resume
{
    self.downloadSuccuss = succuss;
    self.downloadFail = fail;
    self.downloadProgress = progress;
    self.downloadCancle = cancle;
    self.downloadPause = pause;
    self.downloadResume = resume;
    
    self.identifier = identifier ? identifier : [[NSProcessInfo processInfo] globallyUniqueString];
    // 中文 特殊字符  转码
    downLoadUrl = [downLoadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    if (isDownLoadBackground) {
        [self startBackgroundDownload:downLoadUrl identifier:self.identifier];
    } else {
        [self startNormalDownload:downLoadUrl identifier:self.identifier];
    }
}



#pragma mark ------
#pragma mark 下载任务的控制
- (void)startBackgroundDownload:(NSString *)downloadStr identifier:(NSString *)identifier {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadStr]];
    self.backgroundSession = [self getBackgroundSession:identifier];
    self.backgroundSessionTask = [self.backgroundSession downloadTaskWithRequest:request];
    [self.backgroundSessionTask resume];
}

- (void)startNormalDownload:(NSString *)downloadStr identifier:(NSString *)identifier{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadStr]];
    self.normalSessionTask = [self.normalSession downloadTaskWithRequest:request];
    self.normalSessionTask.taskDescription = identifier;
    [self.normalSessionTask resume];
}


- (void)pauseDownLoadWithIdentifier:(NSString *)identifier
{
    __weak typeof(self) this = self;
    if (self.normalSessionTask) {
        [self.normalSessionTask cancelByProducingResumeData:^(NSData *resumeData) {
            this.partialData = resumeData;
            this.normalSessionTask = nil;
        }];
    }
    else if (self.backgroundSessionTask) {
        [self.backgroundSessionTask cancelByProducingResumeData:^(NSData *resumeData) {
            this.partialData = resumeData;
        }];
    }

    self.downloadPause([self getDownloadRespose:WLDownloadPause identifier:self.identifier progress:self.lastProgress downloadUrl:nil downloadSaveFileUrl:nil downloadData:nil downloadResult:@"任务暂停" lastProgress:0.0]);
}

- (void)resumeDownLoadWithIdentifier:(NSString *)identifier
{
    if (!self.partialData && identifier.length > 0) {
        self.partialData = [WLDownLoadUtil getResumeDataWithIdentifier:identifier];
        NSLog(@"read resumedata from file");
    }
    
    if (self.partialData) {
        self.backgroundSessionTask = [self.backgroundSession downloadTaskWithResumeData:self.partialData];
        [self.backgroundSessionTask resume];
    } else {
        self.downloadFail([self getDownloadRespose:WLDownloadFail identifier:self.identifier progress:0.00 downloadUrl:nil downloadSaveFileUrl:nil downloadData:nil downloadResult:@"没有需要恢复的任务" lastProgress:0.0]);
        return;
    }
    self.downloadResume([self getDownloadRespose:WLDownloadResume identifier:self.identifier progress:self.lastProgress downloadUrl:nil downloadSaveFileUrl:nil downloadData:nil downloadResult:@"任务重启" lastProgress:0.0]);
}

- (void)cancleDownLoadIdentifier:(NSString *)identifier
{
    if (self.normalSessionTask) {
        [self.normalSessionTask cancel];
        self.normalSessionTask = nil;
    } else if (self.backgroundSessionTask) {
        [self.backgroundSessionTask cancel];
        self.backgroundSessionTask = nil;
    }
    self.downloadCancle([self getDownloadRespose:WLDownloadCancle identifier:self.identifier progress:self.lastProgress downloadUrl:nil downloadSaveFileUrl:nil downloadData:nil downloadResult:@"任务取消" lastProgress:0.0]);
}


#pragma mark - NSURLSessionDownloadDelegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double currentProgress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    NSLog(@"%@---%0.2f",self.identifier,currentProgress);
    
        if (currentProgress >= self.lastProgress+0.005 || currentProgress == 1.00 || currentProgress == 0) {
    double temp = self.lastProgress;
    self.lastProgress = currentProgress;
    
    self.downloadProgress([self getDownloadRespose:WLDownloading identifier:self.identifier progress:currentProgress downloadUrl:nil downloadSaveFileUrl:nil downloadData:nil downloadResult:@"下载中" lastProgress:temp]);
        }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // We've successfully finished the download. Let's save the file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *str = [WLDownLoadUtil successDataSavePathWithIdentifier:self.identifier];
    
    NSURL *destinationPath = [NSURL fileURLWithPath:str];
    NSLog(@"电影保存路径  =========  %@", str);
    
    NSError *error;
    
    // Make sure we overwrite anything that's already there
    [fileManager removeItemAtURL:destinationPath error:NULL];
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationPath error:&error];
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 此处可更新UI
        });
        self.downloadSuccuss([self getDownloadRespose:WLDownloadSuccuss identifier:self.identifier progress:1.00 downloadUrl:nil downloadSaveFileUrl:destinationPath downloadData:nil downloadResult:@"下载成功" lastProgress:0.0]);
    } else {
        NSLog(@"Couldn't copy the downloaded file");
        self.downloadFail([self getDownloadRespose:WLDownloadFail identifier:self.identifier progress:0.00 downloadUrl:nil downloadSaveFileUrl:destinationPath downloadData:nil downloadResult:@"下载失败" lastProgress:0.0]);
    }
    
    if(downloadTask == self.normalSessionTask) {
        self.normalSessionTask = nil;
    } else if (session == self.backgroundSession) {
        self.backgroundSessionTask = nil;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.backgroundURLSessionCompletionHandler) {
            void (^handler)() = appDelegate.backgroundURLSessionCompletionHandler;
            appDelegate.backgroundURLSessionCompletionHandler = nil;
            handler();
            
            NSLog(@"后台下载完成");
        }
        
        self.downloadSuccuss([self getDownloadRespose:WLDownloadBackgroudSuccuss identifier:self.identifier progress:1.00 downloadUrl:nil downloadSaveFileUrl:destinationPath downloadData:nil downloadResult:@"后台下载下载成功" lastProgress:0.0]);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (!self.backgroundSessionTask && [task isKindOfClass:[NSURLSessionDownloadTask class]]) {
        self.backgroundSessionTask = (NSURLSessionDownloadTask *)task;
    }
    NSLog(@"%s", __func__);
    NSLog(@"session identifier = %@, task url = %@", session.configuration.identifier, task.originalRequest.URL.absoluteString);
    if (error) {
        NSLog(@"error =%@", error);
        // check if resume data are available
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            //通过之前保存的resumeData，获取断点的NSURLSessionTask，调用resume恢复下载
            self.partialData = resumeData;
            if (self.partialData) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [WLDownLoadUtil saveResumeData:self.partialData withIdentifier:self.identifier];
                });
            }
            NSLog(@"resumeData = %@", [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding]);
        }
    } else {
        [self resumeDownLoadWithIdentifier:self.identifier];
    }
    
}


#pragma mark -----
#pragma mark lazyload
- (NSURLSession *)getBackgroundSession:(NSString *)identifier {
    NSURLSession *backgroundSession = nil;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"background-NSURLSession-%@",identifier]];
    config.HTTPMaximumConnectionsPerHost = 5;
    backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    return backgroundSession;
}


- (NSURLSession *)normalSession {
    if (!_normalSession) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _normalSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        _normalSession.sessionDescription = @"normal NSURLSession";
    }
    return _normalSession;
}

- (WLDownLoadResponse *)downloadResponse {
    if (!_downloadResponse) {
        _downloadResponse = [[WLDownLoadResponse alloc] init];
    }
    
    return _downloadResponse;
}

- (WLDownLoadResponse *)getDownloadRespose:(WLDownloadStatus)status identifier:(NSString *)identifier progress:(double)progress downloadUrl:(NSString *)downloadUrl downloadSaveFileUrl:(NSURL *)downloadSaveFileUrl downloadData:(NSData *)downloadData downloadResult:(NSString *)downloadResult lastProgress:(double)lastProgress{
    self.downloadResponse.downloadStatus = status;
    self.downloadResponse.identifier = identifier;
    self.downloadResponse.progress = progress;
    self.downloadResponse.downloadUrl = downloadUrl;
    self.downloadResponse.downloadSaveFileUrl = downloadSaveFileUrl;
    self.downloadResponse.downloadData = downloadData;
    self.downloadResponse.downloadResult = downloadResult;
    self.downloadResponse.lastProgress = lastProgress;
    
    return self.downloadResponse;
};



@end
