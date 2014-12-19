//
//  DBPurchase.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DBPurchase.h"
#import "AppController.h"

@implementation DBPurchase

@synthesize purchaseID,purchaseName,purchaseIcon,purchaseDetail,purchaseType,purchaseItem,purchaseCost,maxAmountPurchasable,activeNoOfPurchases,addedToWritableList;

-(id)initWithPrimaryKey:(NSInteger)Ppk database:(sqlite3 *)Pdb{
    if ((self=[super init])) {
        appDelegate=[[UIApplication sharedApplication] delegate];
        
        sqlite3_stmt *init_statement = nil;
        primaryKey = Ppk;
        
        if (init_statement == nil) {
            const char *sqlf = "SELECT * FROM purchase WHERE purchaseID=?";
            if (sqlite3_prepare_v2(Pdb, sqlf, -1, &init_statement, NULL) != SQLITE_OK) {
				NSLog(@"%s", sqlite3_errmsg(Pdb));
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(Pdb));
            }
        }
        
        sqlite3_bind_int(init_statement, 1, primaryKey);
        
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			self.purchaseID=primaryKey;
			self.purchaseName=[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 1)];
			self.purchaseIcon=[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 2)];
			self.purchaseDetail=[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 3)];
			self.purchaseType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 4)];
			self.purchaseItem=sqlite3_column_int(init_statement,5);
            self.purchaseCost=sqlite3_column_int(init_statement,6);
            self.maxAmountPurchasable=sqlite3_column_int(init_statement,7);
            self.activeNoOfPurchases=sqlite3_column_int(init_statement,8);
        } else {
			
			self.purchaseID=0;
			self.purchaseName=@"nil";
			self.purchaseIcon=@"nil";
			self.purchaseDetail=@"nil";
			self.purchaseType=@"nil";
			self.purchaseItem=0;
            self.purchaseCost=0;
            self.maxAmountPurchasable=0;
            self.activeNoOfPurchases=0;
        }
        
        sqlite3_reset(init_statement);
        sqlite3_finalize(init_statement);
        init_statement=nil;
    }
    return self;
}

-(int)insertIntoDatabase:(sqlite3 *)Pdb{
    sqlite3_stmt *insert_statement = nil;
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO purchase(purchaseName,purchaseIcon,purchaseDetail,purchaseType,purchaseItem,purchaseCost,maxAmountPurchasable,activeNoOfPurchases) VALUES(?,?,?,?,?,?,?,?)";
        if (sqlite3_prepare_v2(Pdb, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSLog(@"Insert");
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(Pdb));
        }
    }
    
    sqlite3_bind_text(insert_statement, 1, [purchaseName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 2, [purchaseIcon UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 3, [purchaseDetail UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 4, [purchaseType UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,5, purchaseItem);
    sqlite3_bind_int(insert_statement,6, purchaseCost);
    sqlite3_bind_int(insert_statement,7, maxAmountPurchasable);
    sqlite3_bind_int(insert_statement,8, activeNoOfPurchases);
    
    int success = sqlite3_step(insert_statement);
    
    sqlite3_reset(insert_statement);
    sqlite3_finalize(insert_statement);
    insert_statement=nil;
    
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(Pdb));
		primaryKey = 0;
    } else {
		NSLog(@"Inserted upgrade Successfully...");
        purchaseID=primaryKey=(NSInteger)sqlite3_last_insert_rowid(Pdb);
    }
	return primaryKey;
}

-(BOOL)updateDatabase:(NSInteger)Ppk database:(sqlite3 *)Pdb{
    primaryKey = Ppk;
    
    sqlite3_stmt *update_statement = nil;
    if (update_statement == nil) {
		
        static char *sqlu = "UPDATE purchase SET purchaseName=?,purchaseIcon=?,purchaseDetail=?,purchaseType=?,purchaseItem=?,purchaseCost=?,maxAmountPurchasable=?,activeNoOfPurchases=? WHERE purchaseID=?";
        if (sqlite3_prepare_v2(Pdb, sqlu, -1, &update_statement, NULL) != SQLITE_OK) {
			NSLog(@"Update");
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(Pdb));
        }
    }
	
    sqlite3_bind_text(update_statement, 1, [purchaseName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(update_statement, 2, [purchaseIcon UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(update_statement, 3, [purchaseDetail UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(update_statement, 4, [purchaseType UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(update_statement, 5, purchaseItem);
    sqlite3_bind_int(update_statement, 6, purchaseCost);
    sqlite3_bind_int(update_statement, 7, maxAmountPurchasable);
    sqlite3_bind_int(update_statement, 8, activeNoOfPurchases);
	sqlite3_bind_int(update_statement, 9, primaryKey);
	
    int success = sqlite3_step(update_statement);
    
    if(success==SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(Pdb));
    } else {
        NSLog(@"Updated upgrade Successfully...");
    }
	
    sqlite3_reset(update_statement);
    sqlite3_finalize(update_statement);
    update_statement=nil;
    
    return success;
}

-(BOOL)deleteDatabase:(NSInteger)Ppk database:(sqlite3 *)Pdb{
    primaryKey = Ppk;
    
    sqlite3_stmt *delete_statement = nil;
    if (delete_statement == nil) {
        static char *sqlu = "DELETE FROM purchase WHERE purchaseID=?";
        if (sqlite3_prepare_v2(Pdb, sqlu, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(Pdb));
        }
    }
    
	sqlite3_bind_int(delete_statement, 1, primaryKey);
    int success = sqlite3_step(delete_statement);
    if(success==SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(Pdb));
    } else {
        NSLog(@"Deleted Successfully...");
    }
	
    sqlite3_reset(delete_statement);
    sqlite3_finalize(delete_statement);
    delete_statement=nil;
    
    return success;
}

-(BOOL)updateDatabaseForPurchase{
    if (self.purchaseCost<=appDelegate.databaseManager.userData.uCoins) {
        appDelegate.databaseManager.userData.uCoins-=self.purchaseCost;
        //[appDelegate.databaseManager.userData updateDatabase:appDelegate.databaseManager.userData.uID database:appDelegate.databaseManager.database];
        
        self.activeNoOfPurchases+=1;
        //[self updateDatabase:self.purchaseID database:appDelegate.databaseManager.database];
        if (self.addedToWritableList==NO) {
            self.addedToWritableList=YES;
            [appDelegate.databaseManager.dataObjectsToBeWritten addObject:self];
        }
        NSLog(@"object count--->%d",[appDelegate.databaseManager.dataObjectsToBeWritten count]);
        return YES;
    }
    return NO;
}

-(void)dealloc{
    [self.purchaseName release];
    self.purchaseName=nil;
    [self.purchaseIcon release];
    self.purchaseIcon=nil;
    [self.purchaseDetail release];
    self.purchaseDetail=nil;
    [self.purchaseType release];
    self.purchaseType=nil;
    
    [super dealloc];
}

@end