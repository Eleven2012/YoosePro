//
//  MP4Recorder.h
//  2cu
//
//  Created by wutong on 15/9/21.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2PCInterface.h"

@interface MP4Recorder : NSObject

@property (nonatomic) BOOL statusRecordSwitch;

+ (id)sharedDefault;
-(void)startRecordWithID:(NSString*)contactId;
-(void)stopRecord;

-(void)vRecvAVData1:(BYTE*)pAudioData  dwAudioDataLen:(uint32_t)dwAudioDataLen dwFrames:(uint32_t)dwFrames u64APTS:(UINT64)u64APTS pVideoData:(BYTE*)pVideoData dwVideoLen:(DWORD)dwVideoLen u64VPTS:(UINT64)u64VPTS;
-(void)vRecvAVHeader1:(sAVInfoType*) pAVInfo;
@end
