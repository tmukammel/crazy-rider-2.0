//
//  DBUpgrades.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class AppController;

@interface DBUpgrades : NSObject{
@private
    AppController *appDelegate;
    NSInteger primaryKey;
    
    NSArray *steps;
    NSArray *stepCosts;
}

@property (nonatomic,readwrite) int upgradeID,activeStep,noOfUpgradeSteps;
@property (nonatomic,readwrite,retain) NSString *upgradeName,*upgradeIcon,*upgradeDetail,*upgradeType,*upgradeSteps,*upgradeStepCosts,*typeDetail1,*typeDetail2;
@property (nonatomic) BOOL addedToWritableList;

- (id)initWithPrimaryKey:(NSInteger)Upk database:(sqlite3 *)Udb;
- (int)insertIntoDatabase:(sqlite3 *)Udb;
- (BOOL)updateDatabase:(NSInteger)Upk database:(sqlite3 *)Udb;
- (BOOL)deleteDatabase:(NSInteger)Upk database:(sqlite3 *)Udb;
-(float)getCurrentStep;
-(NSArray*)getNextUpgradeStepAndCost;
-(NSArray*)updateDatabaseForStepPurchase;

@end