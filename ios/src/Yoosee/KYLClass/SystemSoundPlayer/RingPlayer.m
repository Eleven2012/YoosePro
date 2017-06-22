//
//  RingPlayer.m
//  VoIP_iPhone
//
//  Created by First Mac on 6/27/11.
//  Copyright 2011 Cienet. All rights reserved.
//

#import "RingPlayer.h"
//#import "MtcLog.h"
//#import "Common.h"
#import <AudioToolbox/AudioServices.h>

static RingPlayer *g_ringPlayer = nil;
static BOOL isSysVolumeResume = YES;
static BOOL isRingPlay = NO;
static int callCount = 0;

@interface RingPlayer(private)

- (void)padTimerFireMethodFinishPlay:(NSTimer *)theTimer;

- (int)vibratePlayThread:(id)param;

- (int)vibrateStopThred:(id)param;

@end

@implementation RingPlayer

- (id)init {
    self = [super init];
    if (self != nil) {
        ringName_ = [[NSArray alloc] initWithObjects:@"Tone0", @"Tone1", 
                     @"Tone2", @"Tone3", @"Tone4", @"Tone5", @"Tone6", @"Tone7",
                     @"Tone8", @"Tone9", @"ToneStar", @"TonePound", @"Ring", 
                     @"RingBack", @"CallFailed", @"Busy", @"CallWait",
                     @"Forward", @"Term", @"Held", @"MsgRecv", nil];
        
        musicPlayerController_ = [MPMusicPlayerController iPodMusicPlayer];
        sysVolume_ = musicPlayerController_.volume;
    }
    return self;
}

- (void)dealloc {
    [player_ release];
    player_ = nil;
    [ringName_ release];
    ringName_ = nil;
    if (padTimer_ != nil) {
        [padTimer_ invalidate];
        padTimer_ = nil;
    }
    [super dealloc];
}

+ (RingPlayer *)defaultRingPlayer {
    if (g_ringPlayer == nil) {
        g_ringPlayer = [[RingPlayer alloc] init];
    }
    return g_ringPlayer;
}

+ (void)releaseDefaultRingPlayer {
    if (g_ringPlayer != nil) {
        [g_ringPlayer ringStop];
        [g_ringPlayer release];
        g_ringPlayer = nil;
    }
}

- (int)ringPlay:(int)type timeLength:(unsigned int)milliSeconds {
    if (type < 0 || type >= E_RING_SIZE) {
        return 1;
    }
#ifdef NOT_PLAY_SOUND
    return 1;
#endif
    
    [self ringStop];
    
    NSString *name = [ringName_ objectAtIndex:type];
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:name ofType:@"wav"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return 1;
    }
	
    NSError *error = nil;
    player_ = [[AVAudioPlayer alloc] initWithContentsOfURL:
			   [NSURL fileURLWithPath:path] error:&error];
    if (player_ == nil) {
        [error release];
        error = nil;
        return 1;
    }
	player_.delegate = self;
    [player_ prepareToPlay];
    if (milliSeconds == 0) {
        [player_ setNumberOfLoops:999999];
    }
    else {
        double doubleloop = ((double)milliSeconds / 1000 / player_.duration);
        int loop = (int)doubleloop;
        if (loop > 0) {
            if ((doubleloop - loop) < 0.5) {
                loop --;
            }
        }
        [player_ setNumberOfLoops:loop];
    }
	
    [player_ play];
    
    return 0;
}

- (int)ringPlay:(int)type numberofLoop:(unsigned int)numberOfLoop {
    if (type < 0 || type >= E_RING_SIZE) {
        return 1;
    }
#ifdef NOT_PLAY_SOUND
    return 1;
#endif
    [self ringStop];
    
    NSString *name = [ringName_ objectAtIndex:type];
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:name ofType:@"wav"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return 1;
    }
    
	NSURL * ringUrl = [NSURL fileURLWithPath:path];
	if (ringUrl == nil) {
		//MtcLogDebug("%s ringplayer uri is nil",  K_CALL_BUSINESS);
		return 1;
	}
    NSError *error = nil;
    player_ = [[AVAudioPlayer alloc] initWithContentsOfURL:ringUrl
													 error:&error];
    if (player_ == nil) {
        [error release];
        error = nil;
        return 1;
    }
	player_.delegate = self;
    BOOL success = [player_ prepareToPlay];
    //modify by lvyi 2011.11.30 如果准备播放失败，需要返回正确的错误码，并且不需要继续播放
    if (!success) {
        return 1;
    }
    isRingPlay = YES;
    [player_ setNumberOfLoops:0];
    //MtcLogDebug("%s ringplayer play start",  K_CALL_BUSINESS);
    vibrateThread_ = [[NSThread alloc] initWithTarget:self
                                             selector:@selector(vibratePlayThread:)
                                               object:player_];
    [vibrateThread_ start];
    
    return 0;
}

- (int)ringPlayInNewThread:(int)type timeLength:(unsigned int)milliSeconds {
    if (type < 0 || type >= E_RING_SIZE) {
        return 1;
    }
#ifdef NOT_PLAY_SOUND
    return 1;
#endif
    [self ringStop];
    
    NSString *name = [ringName_ objectAtIndex:type];
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:name ofType:@"wav"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return 1;
    }
	
    NSError *error = nil;
    player_ = [[AVAudioPlayer alloc] initWithContentsOfURL:
               [NSURL fileURLWithPath:path] error:&error];
    if (player_ == nil) {
        [error release];
        error = nil;
        return 1;
    }
    [player_ prepareToPlay];
    if (milliSeconds == 0) {
        [player_ setNumberOfLoops:999999];
    }
    else {
        double doubleloop = ((double)milliSeconds / 1000 / player_.duration);
        int loop = (int)doubleloop;
        if (loop > 0) {
            if ((doubleloop - loop) < 0.5) {
                loop --;
            }
        }
        [player_ setNumberOfLoops:loop];
    }
    
    playThread_ = [[NSThread alloc] initWithTarget:self
                                          selector:@selector(ringPlayThread:)
                                            object:player_];
    [playThread_ start];
    
    return 0;
}

- (int)ringPlayInNewThread:(int)type numberOfLoop:(unsigned int)numberOfLoop {
    if (type < 0 || type >= E_RING_SIZE) {
        return 1;
    }
#ifdef NOT_PLAY_SOUND
    return 1;
#endif
    [self ringStop];
    
    NSString *name = [ringName_ objectAtIndex:type];
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:name ofType:@"wav"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return 1;
    }
    
    NSError *error = nil;
    player_ = [[AVAudioPlayer alloc] initWithContentsOfURL:
               [NSURL fileURLWithPath:path] error:&error];
    if (player_ == nil) {
        [error release];
        error = nil;
        return 1;
    }
    [player_ prepareToPlay];
    [player_ setNumberOfLoops:numberOfLoop];
    
    playThread_ = [[NSThread alloc] initWithTarget:self
                                          selector:@selector(ringPlayThread:)
                                            object:player_];
    [playThread_ start];
    
    return 0;
}

- (void)ringStop {
    //注意vibrateThread_顺序不能改必须放在第一位
    //【VOIP】点接听后，有时候会有铃声 fix bug by wangyuehong 2012.05.15
    if (vibrateThread_ != nil) {
        [self performSelector:@selector(vibrateStopThred:)
                     onThread:vibrateThread_
                   withObject:nil
                waitUntilDone:NO];
        //MtcLogDebug("%s ring player stop. vibrateThread not nil",  K_CALL_BUSINESS);
        [vibrateThread_ release];
        vibrateThread_ = nil;
    }
    if (player_ != nil) {
        [player_ stop];
        //MtcLogDebug("%s ring player stop. player not nil", K_CALL_BUSINESS);
        [player_ release];
        player_ = nil;
    }
    if (playThread_ != nil) {
        [self performSelector:@selector(ringStopThred:)
                     onThread:playThread_
                   withObject:nil
                waitUntilDone:NO];
        //MtcLogDebug("%s ring player stop. playThread not nil", K_CALL_BUSINESS);
        [playThread_ release];
        playThread_ = nil;
    }
    
    isRingPlay = NO;
}

- (int)ringPlayThread:(id)param {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    BOOL exitNow = NO;
    [dict setValue:[NSNumber numberWithBool:exitNow] forKey:@"ExitNow"];
    
    AVAudioPlayer *player = (AVAudioPlayer *)param;
    [player play];
    
    while (!exitNow) {
		//[runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        [runLoop runUntilDate:[NSDate date]];
        exitNow = [[dict valueForKey:@"ExitNow"] boolValue];
    }
    
    player = nil;
    [pool release];
    
    return 0;
    
}

- (int)vibratePlayThread:(id)param {
    //MtcLogDebug("%s vibratePlayThread() is start.", K_CALL_BUSINESS);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    BOOL vibrateExit = NO;
    [dict setValue:[NSNumber numberWithBool:vibrateExit] forKey:@"vibrateExit"];
    
    AVAudioPlayer *player = (AVAudioPlayer *)param;
    
    while (![[dict valueForKey:@"vibrateExit"] boolValue]) {        
        [player play];
        [runLoop runUntilDate:[NSDate date]];
        //vibrateExit = [[dict valueForKey:@"vibrateExit"] boolValue];
    }
    player = nil;
    [pool release];
    //MtcLogDebug("%s vibratePlayThread() is end.", K_CALL_BUSINESS);
    return 0;
    
}

- (int)ringStopThred:(id)param {
    //MtcLogDebug("%s ringStopThred() is called", K_CALL_BUSINESS);
    NSNumber* temp = [[NSNumber alloc] initWithBool:YES];
    
    [[[NSThread currentThread] threadDictionary] setValue:temp
                                                   forKey:@"ExitNow"];
    //MtcLogDebug("%s setValue() is called.", K_CALL_BUSINESS);
    
    [temp release];
    
    return 0;
}

- (int)vibrateStopThred:(id)param {
    NSNumber* temp = [[NSNumber alloc] initWithBool:YES];
    
    [[[NSThread currentThread] threadDictionary] setValue:temp
                                                   forKey:@"vibrateExit"];
    [temp release];
    
    return 0;
}

- (int)setPlayerVolume:(double)volume {
	if (player_ != nil) {
		if (volume >=0 && volume <= 1) {
			NSLog(@"player volume :%f", volume);
			player_.volume = volume;
		}
	}
	return 0;
}

- (int)keyBoardRingPlay:(int)type {
    if (type < 0 || type >= E_RING_SIZE) {
        return 1;
    }
#ifdef NOT_PLAY_SOUND
    return 1;
#endif
    [self ringStop];
    
    NSString *name = [ringName_ objectAtIndex:type];
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:name ofType:@"wav"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return 1;
    }
    
	NSURL * ringUrl = [NSURL fileURLWithPath:path];
	if (ringUrl == nil) {
		//MtcLogDebug("%s ringplayer uri is nil",  K_CALL_BUSINESS);
		return 1;
	}
    NSError *error = nil;
    player_ = [[AVAudioPlayer alloc] initWithContentsOfURL:ringUrl
													 error:&error];
    if (player_ == nil) {
        [error release];
        error = nil;
        return 1;
    }
	player_.delegate = self;
    BOOL success = [player_ prepareToPlay];
    //modify by lvyi 2011.11.30 如果准备播放失败，需要返回正确的错误码，并且不需要继续播放
    if (!success) {
        return 1;
    }
    
    if (isSysVolumeResume) {
        sysVolume_ = musicPlayerController_.volume;
        musicPlayerController_.volume = 0.3f;
        isSysVolumeResume = NO;
    }
    
    
    [player_ setNumberOfLoops:0];
    [player_ play];
    
    if (padTimer_ != nil) {
        [padTimer_ invalidate];
        padTimer_ = nil;
    }
    padTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                target:self 
                                              selector:@selector(padTimerFireMethodFinishPlay:) 
                                              userInfo:nil 
                                               repeats:NO];
    return 0;
}

- (void)padTimerFireMethodFinishPlay:(NSTimer *)theTimer {
    if (!isSysVolumeResume) {
        musicPlayerController_.volume = sysVolume_;
        isSysVolumeResume = YES;
    }
    if (padTimer_ != nil) {
        [padTimer_ invalidate];
        padTimer_ = nil;
    }
}

- (void)getMPMusicPlaybackState {
    callCount++;
    if (callCount == 1) {
        playbackState_ = [musicPlayerController_ playbackState];
        if (playbackState_ == MPMusicPlaybackStatePlaying) {
            [musicPlayerController_ pause];
        }
    }
}

- (void)restoreMPMusicPlay {
    callCount--;
    if (callCount == 0 && playbackState_ == MPMusicPlaybackStatePlaying) {
        [musicPlayerController_ play];
    }
}

#pragma mark AVAudioPlayerDelegate method
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player 
                       successfully:(BOOL)flag {
	if (isRingPlay) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
	
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    if (player_ != nil && player != nil) {
        [player play];
    }
}

@end
