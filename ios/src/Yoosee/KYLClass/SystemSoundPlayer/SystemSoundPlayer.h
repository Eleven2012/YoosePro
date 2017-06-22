//
//  SystemSoundPlayer.h
//  VoIP_iPhone
//
//  Created by First Mac on 7/6/11.
//  Copyright 2011 Cienet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface SystemSoundPlayer : NSObject {
    NSArray *ringName_;
    SystemSoundID systemSound_;
    UInt32 numberOfLoop_;
    NSThread *systemSoundThread_;
}

+ (SystemSoundPlayer *)defaultSystemSoundPlayer;

+ (void)releaseDefaultSystemSoundPlayer;

- (int)systemSoundPlay:(int)type numberOfLoop:(unsigned int)numberOfLoop;

- (int)alertSoundPlay:(int)type numberOfLoop:(unsigned int)numberOfLoop;

- (void)systemSoundStop;

- (void)playVibrate:(unsigned int)numberOfLoop;

- (int)soundPlayThread:(id)param;

- (int)alertPlayThread:(id)param;

- (int)soundPlayStop:(id)param;

- (int)addSystemSoundCompletion:(id)param;

- (int)addAlertCompletion:(id)param;

@end
