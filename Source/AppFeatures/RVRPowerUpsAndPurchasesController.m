//
//  RVRPowerUpsAndPurchasesController.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RVRPowerUpsAndPurchasesController.h"
#import "AppDelegate.h"
#import "RVRDataBaseManager.h"
#import "DBUpgrades.h"
#import "GameNode.h"

static RVRPowerUpsAndPurchasesController *staticRef=nil;

@interface RVRPowerUpsAndPurchasesController (Private)
-(void)populateDataDictionaries;
-(void)initiateCollectablePowerUp;
-(void)initiateAutomaticPowerUp;
-(void)initiateActivePurchase;
@end

@implementation RVRPowerUpsAndPurchasesController

@synthesize delegate,collectablePowerUps,automaticPowerUps,activePurchases;

enum{
    collectable,
    automatic,
};

-(id)init{
    if ((self=[super init])) {
        appDelegate=(AppController*)[[UIApplication sharedApplication] delegate];
        
        self.collectablePowerUps=[[NSMutableDictionary alloc] init];
        self.automaticPowerUps=[[NSMutableDictionary alloc] init];
        self.activePurchases=[[NSMutableDictionary alloc] init];
        
        [self populateDataDictionaries];
    }
    return self;
}

+(RVRPowerUpsAndPurchasesController*)powerUpsAndPurchasesController{
    if (staticRef==nil) {
        staticRef=[[self alloc] init];
    }
    return staticRef;
}

-(void)populateDataDictionaries{
    for (DBUpgrades *dataObj in appDelegate.databaseManager.powerUpUpgrades) {
        if (dataObj.activeStep>-1 && [dataObj.typeDetail2 isEqualToString:@"collectable"]) {
            [self.collectablePowerUps setObject:dataObj forKey:dataObj.upgradeName];
        }
        else if (dataObj.activeStep>-1 && [dataObj.typeDetail2 isEqualToString:@"automatic"]) {
            [self.automaticPowerUps setObject:dataObj forKey:dataObj.upgradeName];
        }
    }
    for (DBPurchase *dataObj in appDelegate.databaseManager.singlePurchases) {
        if (dataObj.activeNoOfPurchases>0) {
            //NSLog(@"purchase name--->%@",dataObj.purchaseName);
            [self.activePurchases setObject:dataObj forKey:dataObj.purchaseName];
        }
    }
}

-(void)initiateCollectablePowerUp{
    [self.delegate alertWhenDistanceIs:((GameNode*)self.delegate).distanceInMiles+COLLECTABLEAPPEARANCEDIST alertFor:collectable];
//    NSLog(@"collectable power ups");
}

-(void)initiateAutomaticPowerUp{
    DBUpgrades *aPUp=[automaticPowerUps objectForKey:@"Double Value Points"];
    //NSLog(@"current step--->%f",[aPUp getCurrentStep]);
    [self.delegate alertWhenDistanceIs:[aPUp getCurrentStep] alertFor:automatic];
}

-(void)requestForAutomaticPowerUp{
    [self initiateAutomaticPowerUp];
}

-(void)initiateActivePurchase{
    [self.delegate addSuperSpeedyButtons:[self.activePurchases allValues]];
}

/*-(void)dealloc{
    [staticRef release];
    [self.collectablePowerUps removeAllObjects];
    self.collectablePowerUps=nil;
    [self.automaticPowerUps removeAllObjects];
    self.automaticPowerUps=nil;
    [self.activePurchases removeAllObjects];
    self.activePurchases=nil;
    self.delegate=nil;
    
    [super dealloc];
}*/

#pragma MARK - GamePlayObserverDelegate Methods Implementation
-(void)gamePlayStarted{
    isGamePlayRunning=YES;
    if ([self.collectablePowerUps count]>0) {
        [self initiateCollectablePowerUp];
    }
    if ([self.automaticPowerUps count]>0) {
        [self initiateAutomaticPowerUp];
    }
    if ([self.activePurchases count]>0) {
        [self initiateActivePurchase];
    }
}

-(void)gamePlayStoped{
    isGamePlayRunning=NO;
}

-(void)distanceCoveredFor:(int)tag{
//    NSLog(@"distance covered");
    if (tag==collectable) {
        [self.delegate showPowerUpWithKey:[[self.collectablePowerUps allKeys] objectAtIndex:(arc4random()%[[self.collectablePowerUps allKeys] count])]];
    }
    else if (tag==automatic) {
        [self.delegate enablePowerUpWithKey:@"doubleValue"];
    }
}

-(void)newCollectablePowerUpAppearanceRequest{
    [self initiateCollectablePowerUp];
}

-(void)collectablePowerUpCollected:(NSString *)key{
//    NSLog(@"power up collected key--->%@",key);
    [self.delegate enablePowerUpWithKey:key];
    DBUpgrades *pUp=[self.collectablePowerUps objectForKey:key];
    //[appDelegate.gNode performSelector:@selector(disablePowerUpWithKey:) withObject:key afterDelay:[pUp getCurrentStep]];
    CCActionDelay *disableDelay=[CCActionDelay actionWithDuration:[pUp getCurrentStep]];
    CCActionCallFunc *disablePUp=[CCActionCallFunc actionWithTarget:appDelegate.gNode selector:@selector(disablePowerUpWithKey:) object:key];
    CCActionSequence *sequence=[CCActionSequence actions:disableDelay, disablePUp, nil];
    [appDelegate.gNode runAction:sequence];
}

-(void)speedyStarterUsedWithTag:(NSString *)tag{
    DBPurchase *data=[self.activePurchases objectForKey:tag];
    
    data.activeNoOfPurchases-=1;
    //[data updateDatabase:data.purchaseID database:appDelegate.databaseManager.database];
    [appDelegate.databaseManager.dataObjectsToBeWritten addObject:data];
    //NSLog(@"remaining--->%d",data.activeNoOfPurchases);
    
    if (data.activeNoOfPurchases==0) {
        [self.activePurchases removeObjectForKey:data.purchaseName];
    }
    
    [self.delegate startWithSuperSpeed:data.purchaseItem];
}

#pragma MARK - Upgrade And Purchase Alert Delegate Implementation
-(void)powerUpUpgradedWithItem:(DBUpgrades *)dataObj{
    if ([dataObj.typeDetail2 isEqualToString:@"collectable"] && ![self.collectablePowerUps objectForKey:dataObj.upgradeName]) {
        [self.collectablePowerUps setObject:dataObj forKey:dataObj.upgradeName];
    }
    else if([dataObj.typeDetail2 isEqualToString:@"automatic"] && ![self.automaticPowerUps objectForKey:dataObj.upgradeName]){
        [self.automaticPowerUps setObject:dataObj forKey:dataObj.upgradeName];
    }
}

-(void)singlePurchaseMadeWithItem:(DBPurchase *)dataObj{
    if (![self.activePurchases objectForKey:dataObj.purchaseName]) {
        [self.activePurchases setObject:dataObj forKey:dataObj.purchaseName];
    }
}

@end