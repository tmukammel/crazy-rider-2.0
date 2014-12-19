//
//  DBUpgrades.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DBUpgrades.h"
#import "AppController.h"

@interface DBUpgrades (Private)
@end

@implementation DBUpgrades

@synthesize upgradeID,upgradeName,upgradeIcon,upgradeDetail,upgradeType,upgradeSteps,upgradeStepCosts,activeStep,noOfUpgradeSteps,typeDetail1,typeDetail2,addedToWritableList;

-(id)initWithPrimaryKey:(NSInteger)Upk database:(sqlite3 *)Udb{
    if ((self=[super init])) {
        appDelegate=[[UIApplication sharedApplication] delegate];
        
        sqlite3_stmt *init_statement = nil;
        primaryKey = Upk;
        
        if (init_statement == nil) {
            const char *sqlf = "SELECT * FROM upgrades WHERE upgradeID=?";
            if (sqlite3_prepare_v2(Udb, sqlf, -1, &init_statement, NULL) != SQLITE_OK) {
				NSLog(@"%s", sqlite3_errmsg(Udb));
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(Udb));
            }
        }
        
        sqlite3_bind_int(init_statement, 1, primaryKey);
        
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			self.upgradeID=primaryKey;
			self.upgradeName=[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 1)];
			self.upgradeIcon=[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 2)];
			self.upgradeDetail=[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 3)];
			self.upgradeType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 4)];
            NSArray *detail=[NSArray arrayWithArray:[self.upgradeType componentsSeparatedByString:@","]];
            typeDetail1=[[NSString stringWithFormat:@"%@",[detail objectAtIndex:0]] retain];
            typeDetail2=[[NSString stringWithFormat:@"%@",[detail objectAtIndex:1]] retain];
            
			self.upgradeSteps=[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 5)];
            steps=[[NSArray alloc] initWithArray:[self.upgradeSteps componentsSeparatedByString:@","]];
			
            self.upgradeStepCosts=[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 6)];
            stepCosts=[[NSArray alloc] initWithArray:[self.upgradeStepCosts componentsSeparatedByString:@","]];
            
            self.noOfUpgradeSteps=[steps count];
            
            self.activeStep=sqlite3_column_int(init_statement,7);
        } else {
			
			self.upgradeID=0;
			self.upgradeName=@"nil";
			self.upgradeIcon=@"nil";
			self.upgradeDetail=@"nil";
			self.upgradeType=@"nil";
            self.upgradeSteps=@"nil";
            self.upgradeStepCosts=@"nil";
            self.activeStep=-2;
            self.noOfUpgradeSteps=0;
        }
        
        sqlite3_reset(init_statement);
        sqlite3_finalize(init_statement);
        init_statement=nil;
    }
    return self;
}

-(int)insertIntoDatabase:(sqlite3 *)Udb{
    sqlite3_stmt *insert_statement = nil;
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO upgrades(upgradeName,upgradeIcon,upgradeDetail,upgradeType,upgradeSteps,upgradeStepCosts,activeStep) VALUES(?,?,?,?,?,?,?)";
        if (sqlite3_prepare_v2(Udb, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSLog(@"Insert");
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(Udb));
        }
    }
    
    sqlite3_bind_text(insert_statement, 1, [upgradeName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 2, [upgradeIcon UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 3, [upgradeDetail UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 4, [upgradeType UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 5, [upgradeSteps UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 6, [upgradeStepCosts UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,7, activeStep);
    
    int success = sqlite3_step(insert_statement);
    
    sqlite3_reset(insert_statement);
    sqlite3_finalize(insert_statement);
    insert_statement=nil;
    
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(Udb));
		primaryKey = 0;
    } else {
		NSLog(@"Inserted upgrade Successfully...");
        upgradeID=primaryKey=(NSInteger)sqlite3_last_insert_rowid(Udb);
    }
	return primaryKey;
}

-(BOOL)updateDatabase:(NSInteger)Upk database:(sqlite3 *)Udb{
    primaryKey = Upk;
    
    sqlite3_stmt *update_statement = nil;
    if (update_statement == nil) {
		
        static char *sqlu = "UPDATE upgrades SET upgradeName=?,upgradeIcon=?,upgradeDetail=?,upgradeType=?,upgradeSteps=?,upgradeStepCosts=?,activeStep=? WHERE upgradeID=?";
        if (sqlite3_prepare_v2(Udb, sqlu, -1, &update_statement, NULL) != SQLITE_OK) {
			NSLog(@"Update");
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(Udb));
        }
    }
	
    sqlite3_bind_text(update_statement, 1, [upgradeName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(update_statement, 2, [upgradeIcon UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(update_statement, 3, [upgradeDetail UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(update_statement, 4, [upgradeType UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(update_statement, 5, [upgradeSteps UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(update_statement, 6, [upgradeStepCosts UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(update_statement, 7, activeStep);
	sqlite3_bind_int(update_statement, 8, primaryKey);
	
    int success = sqlite3_step(update_statement);
    
    if(success==SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(Udb));
    } else {
        NSLog(@"Updated upgrade Successfully...");
    }
	
    sqlite3_reset(update_statement);
    sqlite3_finalize(update_statement);
    update_statement=nil;
    
    return success;
}

-(BOOL)deleteDatabase:(NSInteger)Upk database:(sqlite3 *)Udb{
    primaryKey = Upk;
    
    sqlite3_stmt *delete_statement = nil;
    if (delete_statement == nil) {
        static char *sqlu = "DELETE FROM upgrades WHERE upgradeID=?";
        if (sqlite3_prepare_v2(Udb, sqlu, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(Udb));
        }
    }
    
	sqlite3_bind_int(delete_statement, 1, primaryKey);
    int success = sqlite3_step(delete_statement);
    if(success==SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(Udb));
    } else {
        NSLog(@"Deleted Successfully...");
    }
	
    sqlite3_reset(delete_statement);
    sqlite3_finalize(delete_statement);
    delete_statement=nil;
    
    return success;
}

-(float)getCurrentStep{
    return [[NSString stringWithFormat:@"%@",[steps objectAtIndex:self.activeStep]] floatValue]; 
}

-(NSArray*)getNextUpgradeStepAndCost{
    int nextStep=self.activeStep+1;
    if (nextStep<self.noOfUpgradeSteps) {
        return [NSArray arrayWithObjects:[steps objectAtIndex:nextStep], [stepCosts objectAtIndex:nextStep], nil];
    }
    else
        return [NSArray arrayWithObjects:@"fully Upgraded", @"0", nil];
}

-(NSArray*)updateDatabaseForStepPurchase{
    int nextStep=self.activeStep+1;
    if (nextStep<self.noOfUpgradeSteps && [[stepCosts objectAtIndex:nextStep] intValue]<=appDelegate.databaseManager.userData.uCoins) {
        appDelegate.databaseManager.userData.uCoins-=[[NSString stringWithFormat:@"%@",[stepCosts objectAtIndex:nextStep]] intValue];
        //[appDelegate.databaseManager.userData updateDatabase:appDelegate.databaseManager.userData.uID database:appDelegate.databaseManager.database];
        
        self.activeStep=nextStep;
        //[self updateDatabase:self.upgradeID database:appDelegate.databaseManager.database];
        if (self.addedToWritableList==NO) {
            self.addedToWritableList=YES;
            [appDelegate.databaseManager.dataObjectsToBeWritten addObject:self];
        }
        NSLog(@"object count from upgrade--->%d",[appDelegate.databaseManager.dataObjectsToBeWritten count]);
        nextStep+=1;
        if (nextStep<self.noOfUpgradeSteps) {
            return [NSArray arrayWithObjects:[steps objectAtIndex:nextStep], [stepCosts objectAtIndex:nextStep], nil];
        }
        else
            return [NSArray arrayWithObjects:@"fully Upgraded", @"0", nil];
    }
    return nil;
}

-(void)dealloc{
    [upgradeName release];
    upgradeName=nil;
    [upgradeIcon release];
    upgradeIcon=nil;
    [upgradeDetail release];
    upgradeDetail=nil;
    [upgradeType release];
    upgradeType=nil;
    [upgradeSteps release];
    upgradeSteps=nil;
    [upgradeStepCosts release];
    upgradeStepCosts=nil;
    [steps release];
    steps=nil;
    [stepCosts release];
    stepCosts=nil;
    [typeDetail1 release];
    typeDetail1=nil;
    [typeDetail2 release];
    typeDetail2=nil;
    
    [super dealloc];
}

@end
