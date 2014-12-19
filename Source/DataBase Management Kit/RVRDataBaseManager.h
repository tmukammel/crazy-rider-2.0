//
//  RVRDataBaseManager.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "DBUserData.h"
#import "DBUpgrades.h"
#import "DBPurchase.h"

@interface RVRDataBaseManager : NSObject{
@private
    float currentAppVersion,lastDBUpdatedVersion;
}

@property (readonly) sqlite3 *database;
@property (nonatomic,readwrite,retain) DBUserData *userData;
@property (nonatomic,readwrite,retain) NSMutableArray *powerUpUpgrades,*singlePurchases,*PUAndPstoreTitles,*dataObjectsToBeWritten;
@property (nonatomic,assign) BOOL highScoreChanged;

@end
