//
//  DBPurchase.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class AppController;

@interface DBPurchase : NSObject{
@private
    AppController *appDelegate;
    NSInteger primaryKey;
}

@property (nonatomic,readwrite) int purchaseID,purchaseItem,purchaseCost,maxAmountPurchasable,activeNoOfPurchases;
@property (nonatomic,readwrite,retain) NSString *purchaseName,*purchaseIcon,*purchaseDetail,*purchaseType;

@property (nonatomic) BOOL addedToWritableList;

- (id)initWithPrimaryKey:(NSInteger)Ppk database:(sqlite3 *)Pdb;
- (int)insertIntoDatabase:(sqlite3 *)Pdb;
- (BOOL)updateDatabase:(NSInteger)Ppk database:(sqlite3 *)Pdb;
- (BOOL)deleteDatabase:(NSInteger)Ppk database:(sqlite3 *)Pdb;
-(BOOL)updateDatabaseForPurchase;

@end