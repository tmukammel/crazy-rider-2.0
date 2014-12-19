//
//  GameNode.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 5/30/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"
#import "RVRPowerUpsAndPurchasesController.h"
#import "PowerUp.h"
#import "GamePlayObserverDelegateProtocol.h"
#import "PauseOrGameOverMenu.h"

#define PI 3.14159265l

#define INITIALSPEED 10.0f//5.0f
#define MAXSPEED (10.0f/70.0f)*160.0f

#define ACCELERATION 0.03F
#define RETARDATION -0.05F

#define TIMETOMAXSPEEDWITHNORMALACC 12.0F

#define NORMALACCELERATION (MAXSPEED-INITIALSPEED)/(TIMETOMAXSPEEDWITHNORMALACC*3600.0F)

#define MILETOPIXELRATIO 70.0l/36000.0l
#define MINTOHRRATIO 1.0l

#define MAXPOINT (480.0F/105.0F)*160.0F//(600.0F/160.0F)*160.0F
#define XSHIFTCONST 140.0F

#define ROADSTRIPESAPCONST 192.0F
#define NOOFROADSTRIPES 8
#define NOOFROADSTRIPESPERCOL 4

#define BARSTRIPESAPCONST 40.0F
#define NOOFSIDEBARSTRIPES 24
#define NOOFSIDEBARSTRIPESPERCOL 12

#define TREESEPCONST 200.0F
#define NOOFTREES 4
#define NOOFTREESPERCOL 2

#define NOOFVEHICLES 6
#define NOOFVEHICLESPERCOL 2

#define COINSSAPCONST 60.0F
#define NOOFCOINS 48
#define NOOFCOINSPERCOL 16

#define VEHICLELANECHANGESPEED 50.0F

#define TWOLESSSPEEDYSTARTERBTNHIDETIME 8.0F

@class AppController;
@class Obstacles;

struct DistMsg {
    float distanceForCollectable;
    float distanceForAutomatic;
    float distanceForSuperSpeedyStarter;
};

@interface GameNode : CCNode<RVRPowerUpsAndPurchasesDelegate,PauseOrGameOverMenuBtnClickDelegate>{
    
@private
    
    AppController *appDelegate;
    CGSize winSize;
    
    CCSprite *sidebarleft;
    CCSprite *sidebarright;
    
    Obstacles *vehicleCollidedWith;
    
    float currentSpeed;
    float speedBeforeSSS;
    float vCurrentSpeed;
    
    BOOL isAccelerating;
    
    NSMutableArray *roadStripes;
    NSMutableArray *sideBarStripes;
    NSMutableArray *trees;
    NSMutableArray *roadOverlays;
    NSMutableArray *vehicleObstacles;
    NSMutableArray *movingVehicles;
    NSMutableArray *bikerPoints;
    NSMutableArray *movingBikerPoints;
    NSMutableArray *movingTrees;
    NSMutableArray *superSpeedyBtns;
    
    NSMutableDictionary *powerUpSpriteObjs;
    
    NSMutableArray *menuButtons;
    
    BOOL isVehicleMoving;
    BOOL isBikerPointsMoving;
    BOOL isTreesMoving;
    
    NSInteger clickedButtonTag;
    
    CCLayerColor *pauseModeLayer;
    
    CCRenderTexture* _rt;
    
    CCSpriteBatchNode *explosionBatchNode;
    NSMutableArray *explosionBNChilds;
    
    int shootCount;
    
    int noOfVs,vCount;
    
    CGRect magneticInductionRect;
    
    BOOL isPUpPCAlertSent;
    
    BOOL isPowerUpMoving;
    PowerUp *movingPUp;
    
    struct DistMsg distMsg;
    BOOL reducingFromMax;
    BOOL shouldAlertForCollectableDisCovrd;
    BOOL waitingForEnablingDoubleValue,waitingForResettingBikerPoints;
    BOOL willBringGameOverMenu;
}

@property (nonatomic,readwrite,retain) id<GamePlayObserverDelegate> delegate;
@property (nonatomic,readwrite,retain) CCSprite *bikeSprite;
@property (nonatomic,readwrite) float bSpeed;
@property (nonatomic,readwrite) double distanceInMiles,speedInMilesPerH;
@property (nonatomic,readwrite) int isBikeAccelerating,gameOverCount;
@property (nonatomic,readwrite,retain) NSMutableArray *collectedBikerPoints;
@property (nonatomic) BOOL hasMagnet,isInvincible,hasAmmo,hasDoubleValuedCoins,hasCoinMultiplier;

+(CCScene *) scene;
-(void)pauseGameOnEnteringBackGround;

@end
