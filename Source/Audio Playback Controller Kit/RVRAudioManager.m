//
//  RVRAudioManager.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 8/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RVRAudioManager.h"

static RVRAudioManager *sharedAudioManager=nil;

@interface RVRAudioManager (Private)
-(void)preloadAllSounds;
@end

@implementation RVRAudioManager

@synthesize mute;

-(id)init{
    if ((self=[super init])) {
        BOOL isMuted=[[NSUserDefaults standardUserDefaults] boolForKey:@"soundState"];
        if (isMuted==NO) {
            [self preloadAllSounds];
        }
        else self.mute=YES;
    }
    return self;
}

+(id)sharedManager{
    if (sharedAudioManager==nil) {
        sharedAudioManager=[[self alloc] init];
    }
    return sharedAudioManager;
}

-(void)preloadAllSounds{
    bgMusic=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bgMusic" ofType:@"mp3"]] error:nil];
    bgMusic.numberOfLoops=-1;
    [bgMusic prepareToPlay];
    
    bikeEngine=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bikeEngine" ofType:@"mp3"]] error:nil];
    bikeEngine.numberOfLoops=-1;
    [bikeEngine prepareToPlay];
    
    buttonClicked=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"buttonClick" ofType:@"mp3"]] error:nil];
    [buttonClicked prepareToPlay];
    
    /*
    coinSound=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"coinSound" ofType:@"mp3"]] error:nil];
    [coinSound prepareToPlay];
    
    firing=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"firing" ofType:@"wav"]] error:nil];
    [firing prepareToPlay];
    
    explosion=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"wav"]] error:nil];
    [explosion prepareToPlay];
    */
    
	CFURLRef coinSoundURL = (CFURLRef ) [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"coinSound" ofType:@"wav"]];
	AudioServicesCreateSystemSoundID (coinSoundURL, &coinSound);
    
	CFURLRef firingSoundURL = (CFURLRef ) [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"firing" ofType:@"wav"]];
	AudioServicesCreateSystemSoundID (firingSoundURL, &firing);
    
    CFURLRef explosionSoundURL = (CFURLRef ) [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"wav"]];
	AudioServicesCreateSystemSoundID (explosionSoundURL, &explosion);
    
    soundsPreloaded=YES;
}

-(void)playBGMusic:(BOOL)play{
    if (!mute) {
        if (bgMusic.playing==NO && play==YES) {
            [bgMusic play];
        }
        else if(bgMusic.playing==YES && play==NO){
            [bgMusic pause];
            bgMusic.currentTime=0;
        }
    }
}

-(void)playBikeEngineSound:(BOOL)play{
    if (!mute) {
        if (bikeEngine.playing==NO && play==YES) {
            [bikeEngine play];
        }
        else if(bikeEngine.playing==YES && play==NO){
            [bikeEngine pause];
            bikeEngine.currentTime=0;
        }
    }
}

-(void)playButtonClickSound:(BOOL)play{
    if (!mute) {
        if (play==YES) {
            if (buttonClicked.playing==NO) {
                [buttonClicked play];
            }
            else if(buttonClicked.playing==YES){
                buttonClicked.currentTime=0;
            }
        }
        else if(buttonClicked.playing==YES && play==NO){
            [buttonClicked pause];
            buttonClicked.currentTime=0;
        }
    }
}

-(void)playCoinCollectionSound{
    if (!mute) {
        AudioServicesPlaySystemSound (coinSound);
    }
}

-(void)playFiringSound{
    if (!mute) {
        AudioServicesPlaySystemSound (firing);
    }
}

-(void)playExplosionSound{
    if (!mute) {
        AudioServicesPlaySystemSound (explosion);
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [player release];
}

-(void)muteAll:(BOOL)isMute{
    mute=isMute;
    if (isMute==YES) {
        soundsPreloaded=NO;
        [bgMusic stop];
        [bgMusic release];
        [bikeEngine stop];
        [bikeEngine release];
        [buttonClicked stop];
        [buttonClicked release];
        AudioServicesDisposeSystemSoundID(coinSound);
        AudioServicesDisposeSystemSoundID(firing);
        AudioServicesDisposeSystemSoundID(explosion);
    }
    else if(isMute==NO && soundsPreloaded==NO){
        [self preloadAllSounds];
        [self playBGMusic:YES];
    }
}

-(void)dealloc{
    [sharedAudioManager release];
    sharedAudioManager=nil;
    [bgMusic release];
    bgMusic=nil;
    [bikeEngine release];
    bikeEngine=nil;
    [buttonClicked release];
    buttonClicked=nil;
    AudioServicesDisposeSystemSoundID(coinSound);
    AudioServicesDisposeSystemSoundID(firing);
    AudioServicesDisposeSystemSoundID(explosion);
    
    [super dealloc];
}

@end
