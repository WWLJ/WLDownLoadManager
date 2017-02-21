//
//  WLDownLoadSingleManager.h
//  WLDownLoadManager
//
//  Created by Mac on 17/2/21.
//  Copyright © 2017年 wwj. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WLDownLoadResponse.h"

typedef void(^downloadSuccuss)(WLDownLoadResponse *response);
typedef void(^downloadFail)(WLDownLoadResponse *response);
typedef void(^downloadProgress)(WLDownLoadResponse *response);
typedef void(^downloadCancle)(WLDownLoadResponse *response);
typedef void(^downloadPause)(WLDownLoadResponse *response);
typedef void(^downloadResume)(WLDownLoadResponse *response);

@interface WLDownLoadSingleManager : NSObject

/**
 唯一标识
 */
@property (nonatomic, strong) NSString *identifier;


- (void)setDownLoadTaskInfo:(NSString *) downLoadUrl
      isDownloadBackground:(BOOL)isDownLoadBackground
                identifier:(NSString *)identifier
                   succuss:(void (^)(WLDownLoadResponse *response)) succuss
                      fail:(void(^)(WLDownLoadResponse *response)) fail
                  progress:(void(^)(WLDownLoadResponse *response)) progress
                    cancle:(void(^)(WLDownLoadResponse *response)) cancle
                     pause:(void(^)(WLDownLoadResponse *response)) pause
                    resume:(void(^)(WLDownLoadResponse *response)) resume;

- (void)pauseDownLoad;
- (void)resumeDownLoad;
- (void)cancleDownLoad;



@end
