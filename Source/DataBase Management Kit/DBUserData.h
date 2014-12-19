//
//  DBUserData.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class AppController;

@interface DBUserData : NSObject{
@private
    AppController *appDelegate;
    NSInteger primaryKey;
}

@property (nonatomic,readwrite,retain) NSString *UDID,*uName,*c2,*c3;
@property (nonatomic,readwrite) int uID,uCoins;
@property (nonatomic,readwrite) int64_t myHighScore;

- (id)initWithPrimaryKey:(NSInteger)UDpk database:(sqlite3 *)UDdb;
- (int)insertIntoDatabase:(sqlite3 *)UDdb;
- (BOOL)updateDatabase:(NSInteger)UDpk database:(sqlite3 *)UDdb;
- (BOOL)deleteDatabase:(NSInteger)UDpk database:(sqlite3 *)UDdb;

@end
