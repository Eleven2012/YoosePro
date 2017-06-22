//
//  RingPlayer.h
//  VoIP_iPhone
//
//  Created by First Mac on 6/27/11.
//  Copyright 2011 Cienet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import "RingType.h"

@interface RingPlayer : NSObject <AVAudioPlayerDelegate>{
    AVAudioPlayer *player_;
    NSArray *ringName_;
    NSThread *playThread_;
    MPMusicPlayerController *musicPlayerController_;
    float sysVolume_;
    NSTimer *padTimer_;
    NSThread *vibrateThread_;
    MPMusicPlaybackState playbackState_;
}

+ (RingPlayer *)defaultRingPlayer;

+ (void)releaseDefaultRingPlayer;

- (int)ringPlay:(int)type timeLength:(unsigned int)milliSeconds;

- (int)ringPlay:(int)type numberofLoop:(unsigned int)numberOfLoop;

- (int)ringPlayInNewThread:(int)type timeLength:(unsigned int)milliSeconds;

- (int)ringPlayInNewThread:(int)type numberOfLoop:(unsigned int)numberOfLoop;

- (void)ringStop;

- (int)ringPlayThread:(id)param;

- (int)ringStopThred:(id)param;

- (int)setPlayerVolume:(double)volume;

- (int)keyBoardRingPlay:(int)type;

- (void)getMPMusicPlaybackState;

- (void)restoreMPMusicPlay;
@end
