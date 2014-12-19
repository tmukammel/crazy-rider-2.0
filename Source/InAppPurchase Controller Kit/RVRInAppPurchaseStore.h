//
//  RVRInAppPurchaseStore.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RootViewController.h"

#define NOOFPURCHASEITEMS 4

@class AppController;
@class LoadingView;

@interface RVRInAppPurchaseStore : RootViewController{
@private
    AppController *appDelegate;
    CGSize winSize;
    LoadingView *loadingView;
    BOOL purchaseRequestSent;
}

+(id)inAppStore;
-(void)uiViewAnimaitonDidFinish:(id)sender;
-(void)updatePurchaseForAmountIndx:(NSInteger)indx;
-(void)purchaseFailed;
-(void)removeLoading;

@end
