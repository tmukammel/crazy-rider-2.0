//
//  RVRDataBaseManager.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RVRDataBaseManager.h"

@interface RVRDataBaseManager (Private)
-(BOOL)createEditableCopyOfDatabaseIfNeeded;
-(void)createConnectionToDataBase;
-(void)updateDBVersion;

#pragma MARK - userData
-(DBUserData*)initializeUserData;

#pragma MARK - Store
-(void)loadPowerUpUpgrades;
-(void)loadSinglePurchases;

@end

@implementation RVRDataBaseManager

@synthesize database,userData,powerUpUpgrades,singlePurchases,PUAndPstoreTitles,dataObjectsToBeWritten,highScoreChanged;

-(id)init{
    if ((self=[super init])) {
        if ([self createEditableCopyOfDatabaseIfNeeded]) {
            
            PUAndPstoreTitles=[[NSMutableArray alloc] init];
            dataObjectsToBeWritten=[[NSMutableArray alloc] init];
            
            [self createConnectionToDataBase];
            self.userData=[self initializeUserData];
            [self loadPowerUpUpgrades];
            [self loadSinglePurchases];
        }
    }
    return self;
}

-(BOOL)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"scores.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return success;
	
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"scores.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
    return success;
}

-(void)createConnectionToDataBase{
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"scores.sqlite"];
    
    // Open the database
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
		currentAppVersion = [versionString floatValue];
		NSLog(@"CurrentVersion: %f LastUpdatedVersion: %f", currentAppVersion, lastDBUpdatedVersion);
		
		if(currentAppVersion>lastDBUpdatedVersion)
		    [self updateDBVersion];
        /*
         [self loadScoresFromDB];
         [self Multiplayer_Table];
         //        [Goal_Node create_table];
         */
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

-(void)updateDBVersion {
	NSNumber *updatedDBVersion = [NSNumber numberWithFloat:currentAppVersion];
	[[NSUserDefaults standardUserDefaults] setObject:updatedDBVersion forKey:@"lastDBUpdatedVersion"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(DBUserData*)initializeUserData{
    NSString *deviceUDID = [[UIDevice currentDevice] uniqueIdentifier];
	NSString *str_user = [NSString stringWithFormat:@"SELECT uID FROM userData WHERE UDID='%@'", deviceUDID];
    
	const char *sql_user = [str_user cStringUsingEncoding:NSUTF8StringEncoding];
	sqlite3_stmt *statement_user=nil;
	
    DBUserData *myUserData=nil;
    
    if (sqlite3_prepare_v2(self.database, sql_user, -1, &statement_user, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement_user) == SQLITE_ROW) {
			int primaryKeyUser = sqlite3_column_int(statement_user, 0);
			myUserData = [[DBUserData alloc] initWithPrimaryKey:primaryKeyUser database:self.database];
		}
        sqlite3_reset(statement_user);
        sqlite3_finalize(statement_user);
        statement_user=nil;
	}
	
    //create New User Data
	if(myUserData==nil) {        
		myUserData=[[DBUserData alloc] init];
		
        myUserData.UDID=deviceUDID;
        myUserData.uName=@"Your Name";
		myUserData.uCoins =0;
		myUserData.myHighScore=0;
		myUserData.c2=@"nil";
		myUserData.c3=@"nil";
        [myUserData insertIntoDatabase:self.database];
        
//		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isMusicOn"];
	}
    return myUserData;
}

-(void)loadPowerUpUpgrades{
    self.powerUpUpgrades=[[NSMutableArray alloc] init];
    
	NSString *str_fishes=@"SELECT upgradeID FROM upgrades";
	const char *sql_fishes = [str_fishes cStringUsingEncoding:NSUTF8StringEncoding];
	sqlite3_stmt *statement_upgrades=nil;
	
	if (sqlite3_prepare_v2(self.database, sql_fishes, -1, &statement_upgrades, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement_upgrades) == SQLITE_ROW) {
			int primaryKeyUpgrade = sqlite3_column_int(statement_upgrades, 0);
			
			DBUpgrades *upgrade = [[DBUpgrades alloc] initWithPrimaryKey:primaryKeyUpgrade database:self.database];
			[self.powerUpUpgrades addObject:upgrade];
			[upgrade release];
		}
        sqlite3_reset(statement_upgrades);
        sqlite3_finalize(statement_upgrades);
        statement_upgrades=nil;
	}
    [PUAndPstoreTitles addObject:@"sectionView1"];
}

-(void)loadSinglePurchases{
    self.singlePurchases=[[NSMutableArray alloc] init];
    
	NSString *str_fishes=@"SELECT purchaseID FROM purchase";
	const char *sql_fishes = [str_fishes cStringUsingEncoding:NSUTF8StringEncoding];
	sqlite3_stmt *statement_purchase=nil;
	
	if (sqlite3_prepare_v2(self.database, sql_fishes, -1, &statement_purchase, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement_purchase) == SQLITE_ROW) {
			int primaryKeyUpgrade = sqlite3_column_int(statement_purchase, 0);
			
			DBPurchase *purchase = [[DBPurchase alloc] initWithPrimaryKey:primaryKeyUpgrade database:self.database];
			[self.singlePurchases addObject:purchase];
			[purchase release];
		}
        sqlite3_reset(statement_purchase);
        sqlite3_finalize(statement_purchase);
        statement_purchase=nil;
	}
    [PUAndPstoreTitles addObject:@"sectionView2"];
}

-(void)dealloc{
    database=nil;
    [userData release];
    userData=nil;
    [self.powerUpUpgrades removeAllObjects];
    self.powerUpUpgrades=nil;
    [self.singlePurchases removeAllObjects];
    self.singlePurchases=nil;
    [self.PUAndPstoreTitles removeAllObjects];
    self.PUAndPstoreTitles=nil;
    [self.dataObjectsToBeWritten removeAllObjects];
    self.dataObjectsToBeWritten=nil;
    
    [super dealloc];
}

@end
