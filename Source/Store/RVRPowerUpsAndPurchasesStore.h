//
//  RVRPowerUpsAndPurchasesStore.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RootViewController.h"
#import "DBUpgrades.h"
#import "DBPurchase.h"
#import "GamePlayObserverDelegateProtocol.h"

@protocol PowerUpsAndPurchasesAlertDelegate <NSObject>

@required
-(void)powerUpUpgradedWithItem:(DBUpgrades*)dataObj;
-(void)singlePurchaseMadeWithItem:(DBPurchase*)dataObj;

@end

#define NOOFSECTIONS 2
#define HIGHTFORROW 100

#define TABLECELLXOFFSET 64.0F

#define LFONTSIZE 15.0F

@class AppController;

@interface RVRPowerUpsAndPurchasesStore : RootViewController<UITableViewDelegate,UITableViewDataSource>{
@private
    AppController *appDelegate;
    CGSize winSize;
    
    UITableViewController *tVC;
    NSMutableArray *sectionTitleViews;
    
    NSInteger clickedBtntag;
}

+(RVRPowerUpsAndPurchasesStore*)powerUpsAndPurchaseStore;

-(void)uiViewAnimaitonDidFinish;

@property (nonatomic,readwrite,retain) id<ControllerMenu> controllerMenu;
@property (nonatomic,readwrite,retain) id<PowerUpsAndPurchasesAlertDelegate> delegate;

@end
