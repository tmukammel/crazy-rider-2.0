//
//  RVRAudioManager.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 8/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>

@class MixerHostAudio;

@interface RVRAudioManager : NSObject<AVAudioPlayerDelegate>{
@private
    AVAudioPlayer *bgMusic;
    AVAudioPlayer *bikeEngine;
    AVAudioPlayer *buttonClicked;
    SystemSoundID coinSound;
    SystemSoundID firing,explosion;
    
    BOOL soundsPreloaded;
}

+(id)sharedManager;
-(void)muteAll:(BOOL)isMute;
-(void)playBGMusic:(BOOL)play;
-(void)playBikeEngineSound:(BOOL)play;
-(void)playButtonClickSound:(BOOL)play;
-(void)playCoinCollectionSound;
-(void)playFiringSound;
-(void)playExplosionSound;

@property (nonatomic) BOOL mute;

@end
