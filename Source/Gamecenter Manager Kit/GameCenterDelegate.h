//
//  GameCenterDelegate.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"
#import "GamePlayObserverDelegateProtocol.h"

@class AppController;

@interface GameCenterDelegate : NSObject<GameCenterManagerDelegate,GKLeaderboardViewControllerDelegate>{
    AppController *appDelegate;
    
	int64_t  currentScore;
	NSString* cachedHighestScore;
}

@property (nonatomic,readwrite,retain) GameCenterManager *gameCenterManager;
@property (nonatomic, assign) int64_t currentScore,personalBest;
@property (nonatomic, retain) NSString* cachedHighestScore;
@property (nonatomic, retain) NSString* personalBestScoreDescription;
@property (nonatomic, retain) NSString* personalBestScoreString;
@property (nonatomic, retain) NSString* leaderboardHighScoreDescription;
@property (nonatomic, retain) NSString* leaderboardHighScoreString;
@property (nonatomic, retain) NSString* currentLeaderBoard;
@property (nonatomic) BOOL isGameCenterAvailable,isGameCenterAuthOnce;
@property (nonatomic,readwrite,retain) id<ControllerMenu> delegate;

+(id)sharedGameCenterDelegate;

-(void)submitHighScore;
-(void)showLeaderboard;

@end
