//
//  GameCenterDelegate.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCenterDelegate.h"
#import "AppSpecificValues.h"
#import "AppDelegate.h"

static GameCenterDelegate *sharedGameCenterDelegate;

@interface GameCenterDelegate (Private)
-(void)setHighScore;
-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message;
-(void)sendControlToMainMenu:(id)sender;
@end

@implementation GameCenterDelegate

@synthesize gameCenterManager,currentScore,personalBest,cachedHighestScore,personalBestScoreDescription,personalBestScoreString,leaderboardHighScoreDescription,leaderboardHighScoreString,currentLeaderBoard,isGameCenterAvailable,isGameCenterAuthOnce,delegate;

-(id)init{
    if ((self=[super init])) {
        appDelegate=(AppController*)[[UIApplication sharedApplication] delegate];
        self.currentLeaderBoard=kHighestDistance;
        
        if([GameCenterManager isGameCenterAvailable]){
            self.isGameCenterAvailable=YES;
            self.gameCenterManager= [GameCenterManager new];
            [self.gameCenterManager setDelegate: self];
            [self.gameCenterManager authenticateLocalUser];
        }/*
        else{
            UIAlertView* alert= [[[UIAlertView alloc] initWithTitle:@"Game Center Support Required!" message:@"The current device does not support Game Center." delegate: NULL cancelButtonTitle:@"OK" otherButtonTitles: NULL] autorelease];
            [alert show];
        }*/
    }
    return self;
}

+(id)sharedGameCenterDelegate{
    if (sharedGameCenterDelegate==nil) {
        sharedGameCenterDelegate=[[GameCenterDelegate alloc] init];
    }
    return sharedGameCenterDelegate;
}

-(void)submitHighScore{
	if(self.currentScore > 0){
		[self.gameCenterManager reportScore:self.currentScore forCategory:self.currentLeaderBoard];
	}
}

- (void) showLeaderboard;
{
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL) 
	{
		leaderboardController.category = self.currentLeaderBoard;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self; 
		[appDelegate.navController presentViewController:leaderboardController animated:YES completion:nil];
	}
}

-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message{
    [[[UIAlertView alloc] initWithTitle: title message: message
                               delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: NULL] show];
	
}

-(void)sendControlToMainMenu:(id)sender{
    [self.delegate getBackControl];
}

/*-(void)dealloc {
    [sharedGameCenterDelegate release];
    sharedGameCenterDelegate=nil;
    
    [super dealloc];
}*/

#pragma MARK - GameCenterDelegateProtocol Methods Implementation
-(void)processGameCenterAuth:(NSError *)error{
    if(error == NULL){
        self.isGameCenterAuthOnce=YES;
        //submit score
        BOOL isSubmitted=[[NSUserDefaults standardUserDefaults] boolForKey:@"isGCScoreSubmitted"];
        if (isSubmitted==NO) {
            [self setCurrentScore:appDelegate.databaseManager.userData.myHighScore];
            [self submitHighScore];
        }
        else
            [self.gameCenterManager reloadHighScoresForCategory:self.currentLeaderBoard];
	}/*
	else{
		UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: @"Game Center Account Required" message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]] delegate: self cancelButtonTitle: @"Try Again..." otherButtonTitles: NULL] autorelease];
		[alert show];
	}*/
}

-(void)reloadScoresComplete:(GKLeaderboard *)leaderBoard error:(NSError *)error{
    if(error == NULL){
        personalBest= leaderBoard.localPlayerScore.value;
		self.personalBestScoreDescription= @"Your Best:";
		self.personalBestScoreString= [NSString stringWithFormat: @"%lld", personalBest];
		if([leaderBoard.scores count] >0){
			self.leaderboardHighScoreDescription=  @"-";
			self.leaderboardHighScoreString=  @"";
			GKScore* allTime= [leaderBoard.scores objectAtIndex: 0];
			self.cachedHighestScore= allTime.formattedValue;
			[gameCenterManager mapPlayerIDtoPlayer: allTime.playerID];
		}
	}
	else{
		self.personalBestScoreDescription= @"GameCenter Scores Unavailable";
		self.personalBestScoreString=  @"-";
		self.leaderboardHighScoreDescription= @"GameCenter Scores Unavailable";
		self.leaderboardHighScoreDescription=  @"-";
		//[self showAlertWithTitle: @"Score Reload Failed!" message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
}

- (void) mappedPlayerIDToPlayer: (GKPlayer*) player error: (NSError*) error{
	if((error == NULL) && (player != NULL)){
		self.leaderboardHighScoreDescription= [NSString stringWithFormat: @"%@ got:", player.alias];
		
		if(self.cachedHighestScore != NULL){
			self.leaderboardHighScoreString= self.cachedHighestScore;
		}
		else{
			self.leaderboardHighScoreString= @"-";
		}
	}
	else{
		self.leaderboardHighScoreDescription= @"GameCenter Scores Unavailable";
		self.leaderboardHighScoreDescription=  @"-";
	}
}

- (void) scoreReported: (NSError*) error;
{
	if(error == NULL){
        //NSLog(@"submitted...");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isGCScoreSubmitted"];
		[self.gameCenterManager reloadHighScoresForCategory:self.currentLeaderBoard];
		//[self showAlertWithTitle:@"High Score Reported!" message:nil];
	}
	else{/*
		[self showAlertWithTitle: @"Score Report Failed!"
						 message: [NSString stringWithFormat: @"Reason:%@",[error localizedDescription]]];*/
	}
}

#pragma MARK - GKLeaderboardViewControllerDelegate Methods Implementation
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
	[viewController dismissViewControllerAnimated:YES completion:^{
        //[viewController release];
        [self performSelector:@selector(sendControlToMainMenu:) withObject:nil afterDelay:0.5f];
    }];
}

@end
