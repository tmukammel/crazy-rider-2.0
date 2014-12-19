//
//  StoreManager.h
//  MKSync
//
//  Created by Mugunth Kumar on 17-Oct-09.
//  Copyright 2009 MK Inc. All rights reserved.
//  mugunthkumar.com

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MKStoreObserver.h"
#import <UIKit/UIKit.h>
#import "UIDevice-Reachability.h"


@protocol MKStoreKitDelegate <NSObject>
@optional
- (void)productPurchased:(NSString *)productId;
@end

@interface MKStoreManager : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver> {
	NSMutableArray *purchasableObjects;
	MKStoreObserver *storeObserver;	
}
@property (nonatomic, retain) NSMutableArray *purchasableObjects;
@property (nonatomic, retain) MKStoreObserver *storeObserver;

- (void) requestProductData;
- (BOOL) canCurrentDeviceUseFeature: (NSString*) featureID;
- (void) buyFeatureA; // expose product buying functions, do not expose
- (void) buyFeatureB; // your product ids. This will minimize changes when you change product ids later

// do not call this directly. This is like a private method
- (void) buyFeature:(NSString*) featureId;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) provideContent: (NSString*) productIdentifier shouldSerialize: (BOOL) serialize;

+ (MKStoreManager*)sharedManager;
+ (BOOL) featureAPurchased;
+ (BOOL) featureBPurchased: (NSNumber*) purchaseId;
- (void) purchaseAction: (NSNumber*) purchaseNumber;
- (void) purchaseActionSound;

//DELEGATES
+(id)delegate;	
+(void)setDelegate:(id)newDelegate;

@end
