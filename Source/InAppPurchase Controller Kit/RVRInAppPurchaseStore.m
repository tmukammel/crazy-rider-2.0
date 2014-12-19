//
//  RVRInAppPurchaseStore.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RVRInAppPurchaseStore.h"
#import "AppController.h"
#import "cocos2d.h"
#import "RVRPowerUpsAndPurchasesStore.h"
#import "RVRDataBaseManager.h"
#import "MKStoreManager.h"
#import "LoadingView.h"
#import "RVRAudioManager.h"

static RVRInAppPurchaseStore *store=nil;

@interface RVRInAppPurchaseStore (Private)
-(void)createStorePurchaseButtons;
-(void)inAppPurchasebuttonClicked:(id)sender;
-(void)startLoadingPurchase;
@end

@implementation RVRInAppPurchaseStore

int purchasedAmount[] = {2500,25000,75000,200000};

-(id)init{
    if ((self=[super init])) {
        appDelegate=[[UIApplication sharedApplication] delegate];
        winSize=[[CCDirector sharedDirector] winSize];
        
        self.view.frame=self.modalHiddenFrame=CGRectMake(0.0f, -winSize.height, winSize.width, winSize.height);
        self.modalPresentationFrame=CGRectMake(0.0f, 0.0f, winSize.width, winSize.height);
        self.view.backgroundColor=[UIColor clearColor];
        self.view.opaque=NO;
        
        [self createStorePurchaseButtons];
        
        [appDelegate.viewController.view addSubview:self.view];
        [appDelegate.viewController.view sendSubviewToBack:self.view];
    }
    return self;
}

+(id)inAppStore{
    if (store==nil) {
        store=[[self alloc] init];
    }
    return store;
}

-(void)createStorePurchaseButtons{
    CGSize viewSize=self.view.frame.size;
    CGSize btnSize=CGSizeMake(205.0f, 60.0f);
    float yShift=(viewSize.height-(btnSize.height*(NOOFPURCHASEITEMS+1)))/(NOOFPURCHASEITEMS+2);
    
    for (int i=0; i<=NOOFPURCHASEITEMS; i++) {
        UIButton *inAppButton=[UIButton buttonWithType:UIButtonTypeCustom];
        if (i==NOOFPURCHASEITEMS)
            [inAppButton setImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
        else
            [inAppButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"coins%d.png",i]] forState:UIControlStateNormal];
        inAppButton.frame=CGRectMake((viewSize.width-btnSize.width)/2.0f, (yShift*(i+1))+(btnSize.height*i), btnSize.width, btnSize.height);
        inAppButton.bounds=CGRectMake(0.0f, 0.0f, btnSize.width, btnSize.height);
        inAppButton.backgroundColor=[UIColor clearColor];
        [inAppButton addTarget:self action:@selector(inAppPurchasebuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        inAppButton.opaque=NO;
        inAppButton.tag=i;
        [self.view addSubview:inAppButton];
    }
}

-(void)inAppPurchasebuttonClicked:(id)sender{
    //NSLog(@"tag--->%d",[sender tag]);
    [[RVRAudioManager sharedManager] playButtonClickSound:YES];
    if ([sender tag]==NOOFPURCHASEITEMS) {
        [self dismissModalViewAnimated:YES withDelegate:self selector:@selector(uiViewAnimaitonDidFinish:)];
    }
    else if(purchaseRequestSent==NO){
        purchaseRequestSent=YES;
        [self startLoadingPurchase];
        [[MKStoreManager sharedManager] purchaseAction:[NSNumber numberWithInt:[sender tag]]];
    }
}

-(void)startLoadingPurchase{
    loadingView = [LoadingView loadingViewInView:appDelegate.viewController.view];
}

-(void)removeLoading{
	[loadingView removeView];
}

-(void)uiViewAnimaitonDidFinish:(id)sender{
    [appDelegate.viewController presentModalView:[RVRPowerUpsAndPurchasesStore powerUpsAndPurchaseStore] withDelegate:nil selector:nil animated:YES];
}

-(void)purchaseFailed{
    purchaseRequestSent=NO;
}

-(void)updatePurchaseForAmountIndx:(NSInteger)indx{
    appDelegate.databaseManager.userData.uCoins+=purchasedAmount[indx];
    purchaseRequestSent=NO;
    
    NSString *msg = [NSString stringWithFormat:@"Congratulations!!! You have purchased %d coins successfully.", purchasedAmount[indx]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Complete" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)dealloc{
    [store release];
    store=nil;
    
    [super dealloc];
}

@end
