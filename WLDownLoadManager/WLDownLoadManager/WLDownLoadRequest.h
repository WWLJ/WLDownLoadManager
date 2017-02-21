//
//  WLDownLoadRequest.h
//  WLDownLoadManager
//
//  Created by Mac on 17/2/21.
//  Copyright © 2017年 wwj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLDownLoadResponse.h"

@interface WLDownLoadRequest : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) id targert;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, copy) void(^downloadResponse)(WLDownLoadResponse *response);

@end
