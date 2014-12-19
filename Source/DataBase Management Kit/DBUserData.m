//
//  DBUserData.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DBUserData.h"

@implementation DBUserData

@synthesize uID,UDID,uName,uCoins,myHighScore,c2,c3;

-(id)initWithPrimaryKey:(NSInteger)UDpk database:(sqlite3 *)UDdb{
    if ((self = [super init])) {
		sqlite3_stmt *init_statement = nil;
        primaryKey = UDpk;
        
        if (init_statement == nil) {
            const char *sqlf = "SELECT * FROM userData WHERE uID=?";
            if (sqlite3_prepare_v2(UDdb, sqlf, -1, &init_statement, NULL) != SQLITE_OK) {
				NSLog(@"%s", sqlite3_errmsg(UDdb));
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(UDdb));
            }
        }
        
        sqlite3_bind_int(init_statement, 1, primaryKey);
        
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			self.uID = primaryKey;
			self.UDID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 1)];
			self.uName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 2)];
			self.uCoins = sqlite3_column_int(init_statement,3);
			self.myHighScore = sqlite3_column_int64(init_statement,4);
			self.c2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 5)];
			self.c3 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 6)];
        } else {
			
			self.uID = 0;
			self.UDID = @"nil";
			self.uName =@"nil";
			self.uCoins = 0;
			self.myHighScore=0;
			self.c2=@"nil";
            self.c3=@"nil";
        }
        
        sqlite3_reset(init_statement);
        sqlite3_finalize(init_statement);
        init_statement=nil;
    }
    return self;
}

-(int)insertIntoDatabase:(sqlite3 *)UDdb{
    sqlite3_stmt *insert_statement = nil;
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO userData(UDID,uName,uCoins,myHighScore,c2,c3) VALUES(?,?,?,?,?,?)";
        if (sqlite3_prepare_v2(UDdb, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSLog(@"Insert");
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(UDdb));
        }
    }
    
    sqlite3_bind_text(insert_statement, 1, [UDID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 2, [uName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,3, uCoins);
    sqlite3_bind_int64(insert_statement,4, myHighScore);
    sqlite3_bind_text(insert_statement, 5, [c2 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 6, [c3 UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(insert_statement);
    
    sqlite3_reset(insert_statement);
    sqlite3_finalize(insert_statement);
    insert_statement=nil;
    
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(UDdb));
		primaryKey = 0;
    } else {
		NSLog(@"Inserted Product Successfully...");
        uID=primaryKey=(NSInteger)sqlite3_last_insert_rowid(UDdb);
    }
	return primaryKey;
}

-(BOOL)updateDatabase:(NSInteger)UDpk database:(sqlite3 *)UDdb{
    primaryKey = UDpk;
    
    sqlite3_stmt *update_statement = nil;
    if (update_statement == nil) {
		
        static char *sqlu = "UPDATE userData SET UDID=?,uName=?,uCoins=?,myHighScore=?,c2=?,c3=? WHERE uID=?";
        if (sqlite3_prepare_v2(UDdb, sqlu, -1, &update_statement, NULL) != SQLITE_OK) {
			NSLog(@"Update");
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(UDdb));
        }
    }
	
    sqlite3_bind_text(update_statement, 1, [UDID UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(update_statement, 2, [uName UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(update_statement, 3, uCoins);
	sqlite3_bind_int64(update_statement, 4, myHighScore);
	sqlite3_bind_text(update_statement, 5, [c2 UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(update_statement, 6, [c3 UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(update_statement, 7, primaryKey);
	
    int success = sqlite3_step(update_statement);
    
    if(success==SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(UDdb));
    } else {
        NSLog(@"Updated Products Successfully...");
    }
	
    sqlite3_reset(update_statement);
    sqlite3_finalize(update_statement);
    update_statement=nil;
    
    return success;
}

-(BOOL)deleteDatabase:(NSInteger)UDpk database:(sqlite3 *)UDdb{
    primaryKey = UDpk;
    
    sqlite3_stmt *delete_statement = nil;
    if (delete_statement == nil) {
        static char *sqlu = "DELETE FROM userData WHERE uID=?";
        if (sqlite3_prepare_v2(UDdb, sqlu, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(UDdb));
        }
    }
    
	sqlite3_bind_int(delete_statement, 1, primaryKey);
    int success = sqlite3_step(delete_statement);
    if(success==SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(UDdb));
    } else {
        NSLog(@"Deleted Successfully...");
    }
	
    sqlite3_reset(delete_statement);
    sqlite3_finalize(delete_statement);
    delete_statement=nil;
    
    return success;
}

-(void)dealloc{
    [UDID release];
    UDID=nil;
    [uName release];
    uName=nil;
    [c2 release];
    c2=nil;
    [c3 release];
    c3=nil;
    
    [super dealloc];
}

@end
