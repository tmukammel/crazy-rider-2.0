//
//  RVRPowerUpsAndPurchasesController.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVRPowerUpsAndPurchasesStore.h"
#import "GamePlayObserverDelegateProtocol.h"

@class AppController;

#define COLLECTABLEAPPEARANCEDIST 20

@protocol RVRPowerUpsAndPurchasesDelegate <NSObject>

@required
//-(void)instanciatePowerUpEnablers;
-(void)alertWhenDistanceIs:(float)distance alertFor:(int)tag;
-(void)showPowerUpWithKey:(NSString*)key;
-(void)setInvincibilityMode:(BOOL)isYes;
-(void)enablePowerUpWithKey:(NSString*)key;
-(void)disablePowerUpWithKey:(NSString*)key;
-(void)startWithSuperSpeed:(float)distToCover;
-(void)addSuperSpeedyButtons:(NSArray*)values;
@end

@interface RVRPowerUpsAndPurchasesController: NSObject<PowerUpsAndPurchasesAlertDelegate,GamePlayObserverDelegate>{
@private
    AppController *appDelegate;
    
    BOOL isGamePlayRunning;
    
    float lastUsedCollectableUpgradeAppearanceDistance;
}

@property (nonatomic,readwrite,retain) id<RVRPowerUpsAndPurchasesDelegate> delegate;
@property (nonatomic,readwrite,retain) NSMutableDictionary *collectablePowerUps,*automaticPowerUps,*activePurchases;

+(RVRPowerUpsAndPurchasesController*)powerUpsAndPurchasesController;
-(void)requestForAutomaticPowerUp;

@end
