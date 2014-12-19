//
//  RVRPowerUpsAndPurchasesStore.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RVRPowerUpsAndPurchasesStore.h"
#import "AppController.h"
#import "cocos2d.h"
#import "RVRPowerUpsAndPurchasesController.h"
#import "PauseOrGameOverMenu.h"
#import "GameMenu.h"
#import "RVRInAppPurchaseStore.h"
#import "RVRAudioManager.h"

static RVRPowerUpsAndPurchasesStore *storeRef=nil;

@interface RVRPowerUpsAndPurchasesStore (Private)
-(void)addStoreTitleView;
-(void)initiateAndAddTableView;
-(void)initiateSectionViews;
-(void)returnToControllerMenu;
-(void)addOrUpdateCellUpgradeOrPurchaseDetail:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath data:(id)data;
-(void)buttonClicked:(id)sender;
-(void)reloadUpdateAbleData;
@end

@implementation RVRPowerUpsAndPurchasesStore

@synthesize controllerMenu,delegate;

enum{
    nothing,
    doneBtnTag,
    getMoreCoinsBtnTag,
};

-(id)init{
    if ((self=[super init])) {
        appDelegate=[[UIApplication sharedApplication] delegate];
        winSize=[[CCDirector sharedDirector] winSize];
        self.delegate=[RVRPowerUpsAndPurchasesController powerUpsAndPurchasesController];
        
        //self.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;//UIModalTransitionStyleCoverVertical
        
        self.view.frame=self.modalHiddenFrame=CGRectMake(0.0f, -winSize.height, winSize.width, winSize.height);
        self.modalPresentationFrame=CGRectMake(0.0f, 0.0f, winSize.width, winSize.height);
        self.view.backgroundColor=[UIColor clearColor];
        
        [self addStoreTitleView];
        [self initiateSectionViews];
        [self initiateAndAddTableView];
        
        [appDelegate.viewController.view addSubview:self.view];
        [appDelegate.viewController.view sendSubviewToBack:self.view];
    }
    return self;
}

-(void)reloadUpdateAbleData{
    ((UILabel*)[self.view viewWithTag:19]).text=[NSString stringWithFormat:@"%d",appDelegate.databaseManager.userData.uCoins];
}

+(RVRPowerUpsAndPurchasesStore*)powerUpsAndPurchaseStore{
    if (storeRef==nil) {
        storeRef=[[RVRPowerUpsAndPurchasesStore alloc] init];
    }
    [storeRef reloadUpdateAbleData];
    return storeRef;
}

-(void)addStoreTitleView{
    UIButton *getCoinBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [getCoinBtn setImage:[UIImage imageNamed:@"get-more-coins_top.png"] forState:UIControlStateNormal];
    getCoinBtn.frame=CGRectMake(winSize.width/8, 0.0f, winSize.width-((winSize.width/8)*2), 66.0f);
    getCoinBtn.bounds=CGRectMake(0.0f, 0.0f, winSize.width-((winSize.width/8)*2), 66.0f);
    getCoinBtn.backgroundColor=[UIColor clearColor];
    [getCoinBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    getCoinBtn.opaque=NO;
    getCoinBtn.tag=getMoreCoinsBtnTag;
    [self.view addSubview:getCoinBtn];
    
    /*
    UIImageView *storeTitle=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storeTitle.png"]] autorelease];
    storeTitle.frame=CGRectMake(winSize.width/8, 0.0f, winSize.width-((winSize.width/8)*2), (HIGHTFORROW/2.0f)+16.0f);
    storeTitle.opaque=NO;
    [self.view addSubview:storeTitle];
    */
    
    UIImageView *iconView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pCoin.png"]] autorelease];
    iconView.frame=CGRectMake(winSize.width/8+70.0f, 10.0f, 18.0f, 18.0f);
    iconView.opaque=NO;
    [self.view addSubview:iconView];
    
    UILabel *label=[[[UILabel alloc] initWithFrame:CGRectMake(winSize.width/8+100.0f, 10.0f, winSize.width-((winSize.width/8)*2), 20.0f)] autorelease];
    label.text=[NSString stringWithFormat:@"%d",appDelegate.databaseManager.userData.uCoins];
    label.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20.0f];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment=UITextAlignmentLeft;
    label.textColor=[UIColor colorWithRed:1.0f green:1.0f blue:0.12f alpha:1.0f];
    label.backgroundColor=[UIColor clearColor];
    label.opaque=NO;
    label.tag=19;
    [self.view addSubview:label];
    
    
    getCoinBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [getCoinBtn setImage:[UIImage imageNamed:@"get-more-coins_bottom.png"] forState:UIControlStateNormal];
    getCoinBtn.frame=CGRectMake(winSize.width/8, (winSize.height/7)*6, winSize.width-((winSize.width/8)*2)+2.0f, 32.0f);
    getCoinBtn.bounds=CGRectMake(0.0f, 0.0f, winSize.width-((winSize.width/8)*2), 32.0f);
    getCoinBtn.backgroundColor=[UIColor clearColor];
    [getCoinBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    getCoinBtn.opaque=NO;
    getCoinBtn.tag=getMoreCoinsBtnTag;
    [self.view addSubview:getCoinBtn];
    
    UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [doneBtn setImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
    doneBtn.frame=CGRectMake(winSize.width/8, ((winSize.height/7)*6)+34.0f, winSize.width-((winSize.width/8)*2), 32.0f);
    doneBtn.bounds=CGRectMake(0.0f, 0.0f, winSize.width-((winSize.width/8)*2), 32.0f);
    doneBtn.backgroundColor=[UIColor clearColor];
    [doneBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    doneBtn.opaque=NO;
    doneBtn.tag=doneBtnTag;
    [self.view addSubview:doneBtn];
}

-(void)initiateSectionViews{
    sectionTitleViews=[[NSMutableArray alloc] init];
    
    UIImageView *sectionTitleView;
    
    for (NSString *title in appDelegate.databaseManager.PUAndPstoreTitles) {
        
        sectionTitleView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",title]]] autorelease];
        sectionTitleView.frame=CGRectMake(winSize.width/8, winSize.height/7, winSize.width-((winSize.width/8)*2), HIGHTFORROW/2.0f);
        sectionTitleView.opaque=NO;
        [sectionTitleViews addObject:sectionTitleView];
    }
}

-(void)initiateAndAddTableView{
    tVC=[[UITableViewController alloc] initWithNibName:nil bundle:nil];
    tVC.tableView.frame=CGRectMake(winSize.width/8, winSize.height/7, winSize.width-((winSize.width/8)*2), winSize.height-((winSize.height/7)*2));
    tVC.tableView.contentSize=CGSizeMake(winSize.width-((winSize.width/8)*2), winSize.height-((winSize.height/7)*2));
//    NSLog(@"content size -->%f,%f",tVC.tableView.contentSize.width,tVC.tableView.contentSize.height);
    tVC.tableView.delegate = self;
	tVC.tableView.dataSource = self;
	tVC.tableView.opaque = YES;
	tVC.tableView.backgroundColor = [UIColor clearColor];
	tVC.tableView.decelerationRate = 0.5;
	tVC.tableView.bounces = YES;
    tVC.tableView.pagingEnabled=NO;
    //storeTable.transform=CGAffineTransformMakeRotation(-M_PI/2);
    tVC.tableView.separatorColor=[UIColor clearColor];
    tVC.tableView.showsVerticalScrollIndicator=YES;
    tVC.tableView.delaysContentTouches=YES;
    
    [self.view addSubview:tVC.view];
    [tVC release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return NOOFSECTIONS;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return HIGHTFORROW;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HIGHTFORROW/2.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section==0)
        return [appDelegate.databaseManager.powerUpUpgrades count];
    else if(section==1)
        return [appDelegate.databaseManager.singlePurchases count];
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[RVRAudioManager sharedManager] playButtonClickSound:YES];
    UITableViewCell *selectedCell;
    if (indexPath.section==0) {
        DBUpgrades *upgradeData=[appDelegate.databaseManager.powerUpUpgrades objectAtIndex:indexPath.row];
        NSArray *array=[upgradeData updateDatabaseForStepPurchase];
        if (array!=nil) {
            selectedCell=[tableView cellForRowAtIndexPath:indexPath];
            [self addOrUpdateCellUpgradeOrPurchaseDetail:selectedCell indexPath:indexPath data:upgradeData];
            [self.delegate powerUpUpgradedWithItem:upgradeData];
        }
        else if(upgradeData.activeStep+1==upgradeData.noOfUpgradeSteps){
            UIAlertView* alert= [[[UIAlertView alloc] initWithTitle:@"Fully Upgraded!" message:@"Congratulations" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NULL] autorelease];
            [alert show];
        }
        else{
            UIAlertView* alert= [[[UIAlertView alloc] initWithTitle:@"Coin!" message:@"You do not have Enough Coins. Would You like to Buy?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES",NULL] autorelease];
            [alert show];
        }
    }
    else if(indexPath.section==1){
        DBPurchase *purchaseData=[appDelegate.databaseManager.singlePurchases objectAtIndex:indexPath.row];
        BOOL isPurchse=[purchaseData updateDatabaseForPurchase];
        if (isPurchse) {
            selectedCell=[tableView cellForRowAtIndexPath:indexPath];
            [self addOrUpdateCellUpgradeOrPurchaseDetail:selectedCell indexPath:indexPath data:purchaseData];
            [self.delegate singlePurchaseMadeWithItem:purchaseData];
        }
        else{
            UIAlertView* alert= [[[UIAlertView alloc] initWithTitle:@"Coin!" message:@"You do not have Enough Coins. Would You like to Buy?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES",NULL] autorelease];
            [alert show];
        }
    }
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        clickedBtntag=getMoreCoinsBtnTag;
        [self dismissModalViewAnimated:YES withDelegate:self selector:@selector(uiViewAnimaitonDidFinish)];
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [sectionTitleViews objectAtIndex:section];
}

-(void) setImage:(UIImage*)image inTableViewCell:(UITableViewCell*)cell
{
#ifndef __IPHONE_3_0
	cell.image = image;	
#else	
	cell.imageView.image = image;
#endif
}

-(void)addOrUpdateCellUpgradeOrPurchaseDetail:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath data:(id)data{
    NSString *tag=[NSString stringWithFormat:@"100%d%d",indexPath.section,indexPath.row];
    
    UIView *view=[cell.contentView viewWithTag:[tag integerValue]];
    UIImageView *progressView;
    
    if (view==nil) {
        if (indexPath.section==0) {
            DBUpgrades *uData=(DBUpgrades*)data;
            
            view=[[[UIView alloc] initWithFrame:CGRectMake(TABLECELLXOFFSET, LFONTSIZE*4.0f, 27.0f*6.0f, HIGHTFORROW-(LFONTSIZE*4.0f))] autorelease];
            view.opaque=NO;
            view.backgroundColor=[UIColor clearColor];
            view.tag=[tag integerValue];
            
            int j=0;
            for (int i=0; i<uData.noOfUpgradeSteps; i++) {
                progressView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upgradeProgress-bg.png"]] autorelease];
                progressView.frame=CGRectMake((i*27.0f)+(i), 0.0f, 27.0f, 8.0f);
                progressView.opaque=NO;
                progressView.backgroundColor=[UIColor clearColor];
                [view addSubview:progressView];
                
                if (j<=uData.activeStep) {
                    progressView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upgradeProgress.png"]] autorelease];
                    progressView.frame=CGRectMake((i*27.0f)+(i), 0.0f, 27.0f, 8.0f);
                    progressView.opaque=NO;
                    progressView.backgroundColor=[UIColor clearColor];
                    [view addSubview:progressView];
                    j++;
                }
            }
            
            progressView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"purchase-bg.png"]] autorelease];
            progressView.frame=CGRectMake(0.0f, 10.0f, 167.0f, 22.0f);
            progressView.opaque=NO;
            progressView.backgroundColor=[UIColor clearColor];
            
            UILabel *titleLabel=[[[UILabel alloc] initWithFrame:CGRectMake(2.0f, 2.0f, 163.0f, 18.0f)] autorelease];
            titleLabel.text=@"Enable";
            titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:18];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.textAlignment=UITextAlignmentLeft;
            titleLabel.textColor=[UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:1.0f];
            titleLabel.backgroundColor=[UIColor clearColor];
            titleLabel.opaque=NO;
            titleLabel.tag=[[NSString stringWithFormat:@"%d%d",uData.upgradeID,1] integerValue];
            [progressView addSubview:titleLabel];
            
            UIImageView *iconView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pCoin.png"]] autorelease];
            iconView.frame=CGRectMake(80.0f, 2.0f, 18.0f, 18.0f);
            iconView.opaque=NO;
            iconView.tag=[[NSString stringWithFormat:@"%d%d",uData.upgradeID,3] integerValue];
            [progressView addSubview:iconView];
            
            titleLabel=[[[UILabel alloc] initWithFrame:CGRectMake(100.0f, 3.0f, 64.0f, 18.0f)] autorelease];
            NSString *coins=[NSString stringWithFormat:@"%@",[[uData getNextUpgradeStepAndCost] objectAtIndex:1]];
            titleLabel.text=coins;
            titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:16];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.textAlignment=UITextAlignmentLeft;
            titleLabel.textColor=[UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:1.0f];
            titleLabel.backgroundColor=[UIColor clearColor];
            titleLabel.opaque=NO;
            titleLabel.tag=[[NSString stringWithFormat:@"%d%d",uData.upgradeID,2] integerValue];
            [progressView addSubview:titleLabel];
            
            [view addSubview:progressView];
            
            [cell.contentView addSubview:view];
        }
        else if(indexPath.section==1){
            DBPurchase *uData=(DBPurchase*)data;
            
            view=[[[UIView alloc] initWithFrame:CGRectMake(0.0, LFONTSIZE*4.0f, winSize.width-((winSize.width/8)*2), HIGHTFORROW-(LFONTSIZE*4.0f))] autorelease];
            view.opaque=NO;
            view.backgroundColor=[UIColor clearColor];
            view.tag=[tag integerValue];
            
            progressView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"purchase-bg.png"]] autorelease];
            progressView.frame=CGRectMake(TABLECELLXOFFSET, 10.0f, 167.0f, 22.0f);
            progressView.opaque=NO;
            progressView.backgroundColor=[UIColor clearColor];
            
            UILabel *titleLabel=[[[UILabel alloc] initWithFrame:CGRectMake(2.0f, 2.0f, 163.0f, 18.0f)] autorelease];
            titleLabel.text=@"Single Use";
            titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:18];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.textAlignment=UITextAlignmentLeft;
            titleLabel.textColor=[UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:1.0f];
            titleLabel.backgroundColor=[UIColor clearColor];
            titleLabel.opaque=NO;
            [progressView addSubview:titleLabel];
            
            UIImageView *iconView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pCoin.png"]] autorelease];
            iconView.frame=CGRectMake(80.0f, 2.0f, 18.0f, 18.0f);
            iconView.opaque=NO;
            [progressView addSubview:iconView];
            
            titleLabel=[[[UILabel alloc] initWithFrame:CGRectMake(100.0f, 3.0f, 64.0f, 18.0f)] autorelease];
            NSString *coins=[NSString stringWithFormat:@"%d",uData.purchaseCost];
            titleLabel.text=coins;
            titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:16];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.textAlignment=UITextAlignmentLeft;
            titleLabel.textColor=[UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:1.0f];
            titleLabel.backgroundColor=[UIColor clearColor];
            titleLabel.opaque=NO;
            [progressView addSubview:titleLabel];
            
            [view addSubview:progressView];
            
            UILabel *noOfPurchase=[[[UILabel alloc] initWithFrame:CGRectMake(24.0, 16.0f, 16, 16)] autorelease];
            noOfPurchase.text=[NSString stringWithFormat:@"%d",uData.activeNoOfPurchases];
            noOfPurchase.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:14];
            noOfPurchase.adjustsFontSizeToFitWidth = YES;
            noOfPurchase.textAlignment=UITextAlignmentCenter;
            noOfPurchase.textColor=[UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:1.0f];
            noOfPurchase.backgroundColor=[UIColor blackColor];
            noOfPurchase.opaque=NO;
            noOfPurchase.tag=uData.purchaseID;
            [view addSubview:noOfPurchase];
            
            [cell.contentView addSubview:view];
        }
    }
    if (indexPath.section==0) {
        DBUpgrades *uData=(DBUpgrades*)data;
        if (uData.activeStep>-1 && uData.activeStep<uData.noOfUpgradeSteps) {
            progressView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upgradeProgress.png"]] autorelease];
            progressView.frame=CGRectMake((uData.activeStep*27.0f)+(uData.activeStep), 0.0f, 27.0f, 8.0f);
            progressView.opaque=NO;
            progressView.backgroundColor=[UIColor clearColor];
            [view addSubview:progressView];
            
            UILabel *label=(UILabel*)[view viewWithTag:[[NSString stringWithFormat:@"%d%d",uData.upgradeID,1] integerValue]];
            if (uData.activeStep==uData.noOfUpgradeSteps-1 && label!=nil) {
                label.text=[NSString stringWithFormat:@"%@",[[uData getNextUpgradeStepAndCost] objectAtIndex:0]];
            }
            else if (label!=nil) {
                label.text=@"Upgrade";
            }
            
            label=(UILabel*)[view viewWithTag:[[NSString stringWithFormat:@"%d%d",uData.upgradeID,2] integerValue]];
            if (uData.activeStep==uData.noOfUpgradeSteps-1 && label!=nil) {
                [label removeFromSuperview];
                UIImageView *coinView=(UIImageView*)[view viewWithTag:[[NSString stringWithFormat:@"%d%d",uData.upgradeID,3] integerValue]];
                if (coinView!=nil) {
                    [coinView removeFromSuperview];
                }
            }
            else if (label!=nil) {
                NSString *coins=[NSString stringWithFormat:@"%@",[[uData getNextUpgradeStepAndCost] objectAtIndex:1]];
                label.text=coins;
            }
        }
    }
    else if(indexPath.section==1){
        DBPurchase *uData=(DBPurchase*)data;
        UILabel *noOfPurchase=(UILabel*)[view viewWithTag:uData.purchaseID];
        if (noOfPurchase!=nil) {
            noOfPurchase.text=[NSString stringWithFormat:@"%d",uData.activeNoOfPurchases];
        }
    }
    
    UILabel *label=(UILabel*)[self.view viewWithTag:19];
    label.text=[NSString stringWithFormat:@"%d",appDelegate.databaseManager.userData.uCoins];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *MyIdentifier=[NSString stringWithFormat:@"storeDetailCell%d%d",indexPath.section,indexPath.row];
    NSObject *data;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
	if (cell == nil) {
        NSString *iconName,*itemName,*itemDetail;
        
        if (indexPath.section==0){
            data=[appDelegate.databaseManager.powerUpUpgrades objectAtIndex:indexPath.row];
            iconName=((DBUpgrades*)data).upgradeIcon;
            itemName=((DBUpgrades*)data).upgradeName;
            itemDetail=((DBUpgrades*)data).upgradeDetail;
        }
        else if(indexPath.section==1){
            data=[appDelegate.databaseManager.singlePurchases objectAtIndex:indexPath.row];
            iconName=((DBPurchase*)data).purchaseIcon;
            itemName=((DBPurchase*)data).purchaseName;
            itemDetail=((DBPurchase*)data).purchaseDetail;
        }
        
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
		cell.opaque=YES;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"store-tablecell.png"]] autorelease];
        
        UIImageView *iconView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"i%@.png",iconName]]] autorelease];
        iconView.frame=CGRectMake(8.0f, 26.0f, 48.0f, 48.0f);
        iconView.opaque=NO;
        [cell.contentView addSubview:iconView];
        
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(TABLECELLXOFFSET, 0.0f, winSize.width-((winSize.width/8)*2)-TABLECELLXOFFSET, LFONTSIZE)];
        titleLabel.text=itemName;
        titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:LFONTSIZE];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment=UITextAlignmentLeft;
        titleLabel.textColor=[UIColor colorWithRed:65.0f/255.0f green:105.0f/255.0f blue:1.0f alpha:1.0f];
        titleLabel.backgroundColor=[UIColor clearColor];
        titleLabel.opaque=NO;
        [cell.contentView addSubview:titleLabel];
        [titleLabel release];
        
        UILabel *detailLabel=[[UILabel alloc] initWithFrame:CGRectMake(TABLECELLXOFFSET, LFONTSIZE, winSize.width-((winSize.width/8)*2)-TABLECELLXOFFSET, LFONTSIZE*ceilf([itemDetail length]/35.0f))];
        detailLabel.text=itemDetail;
        detailLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:12.0f];
        detailLabel.adjustsFontSizeToFitWidth = NO;
        detailLabel.numberOfLines=ceilf([itemDetail length]/35.0f);
        detailLabel.textAlignment=UITextAlignmentLeft;
        detailLabel.textColor=[UIColor colorWithRed:65.0f/255.0f green:105.0f/255.0f blue:1.0f alpha:1.0f];
        detailLabel.backgroundColor=[UIColor clearColor];
        detailLabel.opaque=NO;
        [cell.contentView addSubview:detailLabel];
        [detailLabel release];
        
        [self addOrUpdateCellUpgradeOrPurchaseDetail:cell indexPath:indexPath data:data];
    }
    else if(indexPath.section==1 && cell!=nil){
        data=[appDelegate.databaseManager.singlePurchases objectAtIndex:indexPath.row];
        [self addOrUpdateCellUpgradeOrPurchaseDetail:cell indexPath:indexPath data:data];
    }
    return cell;
}

-(void)uiViewAnimaitonDidFinish{
    [appDelegate.viewController.view sendSubviewToBack:self.view];
    if ([[PauseOrGameOverMenu menu] reqSent]==YES && clickedBtntag==doneBtnTag) {
        //[[PauseOrGameOverMenu menu] gameOverMenu];
        [[PauseOrGameOverMenu menu] setReqSent:NO];
        appDelegate.gamePlayRunning=NO;
        [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0f scene:[GameMenu scene]]];
    }
    else if(clickedBtntag==getMoreCoinsBtnTag){
        //present InApp Purchase View
        [appDelegate.viewController presentModalView:[RVRInAppPurchaseStore inAppStore] withDelegate:nil selector:nil animated:YES];
    }
    else
        [controllerMenu getBackControl];
    clickedBtntag=nothing;
}

-(void)buttonClicked:(id)sender{
    if ([sender tag]==doneBtnTag || [sender tag]==getMoreCoinsBtnTag) {
        [[RVRAudioManager sharedManager] playButtonClickSound:YES];
        clickedBtntag=[sender tag];
        [self dismissModalViewAnimated:YES withDelegate:self selector:@selector(uiViewAnimaitonDidFinish)];
    }
    else
        clickedBtntag=nothing;
}

-(void)dealloc{
    [storeRef release];
    [sectionTitleViews removeAllObjects];
    sectionTitleViews=nil;
    [tVC release];
    tVC=nil;
    self.delegate=nil;
    
    [super dealloc];
}

@end
