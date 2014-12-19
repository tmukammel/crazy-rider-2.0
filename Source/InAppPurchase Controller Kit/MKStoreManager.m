//
//  MKStoreManager.m
//
//  Created by Mugunth Kumar on 15-Nov-09.
//  Copyright 2009 Mugunth Kumar. All rights reserved.
//  mugunthkumar.com
//

#import "MKStoreManager.h"
#import "cocos2d.h"
#import "LoadingView.h"
#import "RVRInAppPurchaseStore.h"

@implementation MKStoreManager
@synthesize purchasableObjects;
@synthesize storeObserver;

static NSString *ownServer = nil;

#define PRODUCT_ID_0  @"com.insparofaith.crazyrider.2500doodlecoins"
#define PRODUCT_ID_1  @"com.insparofaith.crazyrider.25000doodlecoins"
#define PRODUCT_ID_2  @"com.insparofaith.crazyrider.75000doodlecoins"
#define PRODUCT_ID_3  @"com.insparofaith.crazyrider.200000doodlecoins"

#define SANDBOX	NO

// all your features should be managed one and only by StoreManager
static NSString *featureB0Id = @"com.insparofaith.crazyrider.2500doodlecoins";
static NSString *featureB1Id = @"com.insparofaith.crazyrider.25000doodlecoins";
static NSString *featureB2Id = @"com.insparofaith.crazyrider.75000doodlecoins";
static NSString *featureB3Id = @"com.insparofaith.crazyrider.200000doodlecoins";


BOOL featureAPurchased;
BOOL featureBPurchased[4];
int  featurePurchase=0;

static __weak id<MKStoreKitDelegate> _delegate;
static MKStoreManager* _sharedStoreManager; // self

- (void)dealloc {
	
	[_sharedStoreManager release];
	[storeObserver release];
	[super dealloc];
}

+ (id)delegate {
	
    return _delegate;
}

+ (void)setDelegate:(id)newDelegate {
	
    _delegate = newDelegate;	
}

+(BOOL)featureAPurchased {
	
	return featureAPurchased;
}

+(BOOL)featureBPurchased: (NSNumber*) purchaseId{
	NSNumber *MyPurchase = purchaseId;
	return featureBPurchased[[MyPurchase intValue]];
	//return featureBPurchased;
}

+ (MKStoreManager*)sharedManager
{
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            [[self alloc] init]; // assignment not done here
			_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];			
			//[_sharedStoreManager requestProductData];
			
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
			featureBPurchased[0] = [userDefaults boolForKey:featureB0Id];
			featureBPurchased[1] = [userDefaults boolForKey:featureB1Id];
			featureBPurchased[2] = [userDefaults boolForKey:featureB2Id];
			featureBPurchased[3] = [userDefaults boolForKey:featureB3Id];
			
			_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];
        }
    }
    return _sharedStoreManager;
}


#pragma mark Singleton Methods

+ (id)allocWithZone:(NSZone *)zone

{	
    @synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            _sharedStoreManager = [super allocWithZone:zone];			
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

- (id)retain
{	
    return self;	
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;	
}


- (void) requestProductData
{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
								 [NSSet setWithObjects: featureB0Id, featureB1Id, featureB2Id, featureB3Id, nil]];
	request.delegate = self;
	[request start];
}

/*- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
 {
 [purchasableObjects addObjectsFromArray:response.products];
 // populate UI
 for(int i=0;i<[purchasableObjects count];i++)
 {
 
 SKProduct *product = [purchasableObjects objectAtIndex:i];
 NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
 [[product price] doubleValue], [product productIdentifier]);
 }
 
 [request autorelease];
 }*/

- (void) buyFeatureB
{
	[self buyFeature:featureB0Id];
}

- (void) buyFeature:(NSString*) featureId
{
    
	if([self canCurrentDeviceUseFeature: featureId])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MKStoreKit" message:@"You can use this feature for this session."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		[self provideContent:featureId shouldSerialize:NO];
		return;
	}
	else {
		NSLog(@"Device Not Allowed...");
	}
	
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MKStoreKit" message:@"You are not authorized to purchase from AppStore"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

- (BOOL) canCurrentDeviceUseFeature: (NSString*) featureID
{
	NSString *uniqueID = [[UIDevice currentDevice] uniqueIdentifier];
    
	if(ownServer == nil) return NO; // sanity check
	
	NSURL *url = [NSURL URLWithString:ownServer];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:60];
	
	[theRequest setHTTPMethod:@"POST"];		
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	NSString *postData = [NSString stringWithFormat:@"productid=%@&udid=%@", featureID, uniqueID];
	
	NSString *length = [NSString stringWithFormat:@"%d", [postData length]];	
	[theRequest setValue:length forHTTPHeaderField:@"Content-Length"];	
	
	[theRequest setHTTPBody:[postData dataUsingEncoding:NSASCIIStringEncoding]];
    
	NSHTTPURLResponse* urlResponse = nil;
	NSError *error = [[[NSError alloc] init] autorelease];  
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest
												 returningResponse:&urlResponse 
															 error:&error];  
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    
	BOOL retVal = NO;
	if([responseString isEqualToString:@"YES"])		
	{
		retVal = YES;
	}
	
	[responseString release];
	return retVal;
}

- (void) buyFeatureA
{
	//[self buyFeature:featureAId];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
    [[RVRInAppPurchaseStore inAppStore] purchaseFailed];
}

-(void) provideContent: (NSString*) productIdentifier shouldSerialize: (BOOL) serialize
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	/*if([productIdentifier isEqualToString:featureAId])
	{
		featureAPurchased = YES;
		
		if(serialize)
		{
			if([_delegate respondsToSelector:@selector(productPurchased:)])
				[_delegate productPurchased:productIdentifier];
            
			[userDefaults setBool:featureAPurchased forKey:featureAId];		
		}
	}*/
    
	if([productIdentifier isEqualToString:featureB0Id])
	{
		featureBPurchased[0] = YES;
		[[RVRInAppPurchaseStore inAppStore] updatePurchaseForAmountIndx:0];
		if(serialize)
		{
			if([_delegate respondsToSelector:@selector(productPurchased:)])
				[_delegate productPurchased:productIdentifier];
			[userDefaults setBool:featureBPurchased[0] forKey:featureB0Id];		
		}
	}
	
	if([productIdentifier isEqualToString:featureB1Id])
	{
		featureBPurchased[1] = YES;
        [[RVRInAppPurchaseStore inAppStore] updatePurchaseForAmountIndx:1];
		if(serialize)
		{
			if([_delegate respondsToSelector:@selector(productPurchased:)])
				[_delegate productPurchased:productIdentifier];
			[userDefaults setBool:featureBPurchased[1] forKey:featureB1Id];		
		}
	}
	
	if([productIdentifier isEqualToString:featureB2Id])
	{
		featureBPurchased[2] = YES;
        [[RVRInAppPurchaseStore inAppStore] updatePurchaseForAmountIndx:2];
		if(serialize)
		{
			if([_delegate respondsToSelector:@selector(productPurchased:)])
				[_delegate productPurchased:productIdentifier];
			[userDefaults setBool:featureBPurchased[2] forKey:featureB2Id];		
		}
	}
	
	if([productIdentifier isEqualToString:featureB3Id])
	{
		featureBPurchased[3] = YES;
        [[RVRInAppPurchaseStore inAppStore] updatePurchaseForAmountIndx:3];
		if(serialize)
		{
			if([_delegate respondsToSelector:@selector(productPurchased:)])
				[_delegate productPurchased:productIdentifier];
			[userDefaults setBool:featureBPurchased[3] forKey:featureB3Id];		
		}
	}
}


//////////////////////////////////ADDED NEW CODE FROM ORALLY//////////////////////////////
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	[[RVRInAppPurchaseStore inAppStore] removeLoading];
    [[RVRInAppPurchaseStore inAppStore] purchaseFailed];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction Failed" message:@"Could not contact App Store properly!"
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
	//[self doLog:@"Error: Could not contact App Store properly, %@", [error localizedDescription]];
}

- (void)requestDidFinish:(SKRequest *)request
{
	// Release the request
	[request release];
    [[RVRInAppPurchaseStore inAppStore] purchaseFailed];
}

- (void) repurchase
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	//[BuyBucksNode removeLoading];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	SKProduct *product = [[response products] lastObject];
	if (!product)
	{
        [[RVRInAppPurchaseStore inAppStore] purchaseFailed];
		NSLog(@"Error retrieving product information from App Store. Sorry! Please try again later");
		return;
	}
	
	// Retrieve the localized price
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	[numberFormatter release];
	
	// Create a description that gives a heads up about 
	// a non-consumable purchase
	
    // Directly Purchase the item
    
	if(featurePurchase==0) {
	    SKPayment *payment = [SKPayment paymentWithProductIdentifier:PRODUCT_ID_0];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
		[[RVRInAppPurchaseStore inAppStore] removeLoading];
	}
	else if(featurePurchase==1) {
	    SKPayment *payment = [SKPayment paymentWithProductIdentifier:PRODUCT_ID_1];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
		[[RVRInAppPurchaseStore inAppStore] removeLoading];
	}
	else if(featurePurchase==2) {
	    SKPayment *payment = [SKPayment paymentWithProductIdentifier:PRODUCT_ID_2];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
		[[RVRInAppPurchaseStore inAppStore] removeLoading];
	}
	else if(featurePurchase==3) {
	    SKPayment *payment = [SKPayment paymentWithProductIdentifier:PRODUCT_ID_3];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
		[[RVRInAppPurchaseStore inAppStore] removeLoading];
	}
}

#pragma mark payments
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions{
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [[RVRInAppPurchaseStore inAppStore] removeLoading];
	NSLog(@"Canceled when Password...");
}	

- (void) runningPurchaseTransaction: (SKPaymentTransaction *) transaction{
}

- (void) completedPurchaseTransaction: (SKPaymentTransaction *) transaction{
	// PERFORM THE SUCCESS ACTION THAT UNLOCKS THE FEATURE HERE
	// Finish transaction
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	NSLog(@"Thank you for your purchase.");
}

- (void) restoredPurchaseTransaction: (SKPaymentTransaction *) transaction{
}

- (void) handleFailedTransaction: (SKPaymentTransaction *) transaction
{
	if(transaction.error.code != SKErrorPaymentCancelled) {
		NSLog(@"Transaction Error. Please try again later.");
	}	
	else {
		NSLog(@"Cancelled Here");
	}
	
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions 
{
	for (SKPaymentTransaction *transaction in transactions) {
        
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchasing:
				[self runningPurchaseTransaction:transaction];
				break;
			case SKPaymentTransactionStatePurchased: 
				[self completedPurchaseTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored: 
				[self restoredPurchaseTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed: 
				[self handleFailedTransaction:transaction]; 
				break;
			default: 
				break;
		}
	}
}

- (void) purchaseAction: (NSNumber*) purchaseNumber {
	// Create the product request and start it
	NSNumber *MyPurNumber = purchaseNumber;
	
	/*if (![UIDevice networkAvailable]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"You are not connected to the network!"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
		[BuyBucksNode removeLoading];
	}
	else {*/
		featurePurchase = [MyPurNumber intValue];
		SKProductsRequest *preq;
		
		if(featurePurchase==0)
		    preq = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_ID_0]];
		else if(featurePurchase==1)
			preq = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_ID_1]];
		else if(featurePurchase==2)
			preq = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_ID_2]];
		else if(featurePurchase==3)
			preq = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_ID_3]];
	    
		preq.delegate = self;
	    [preq start];
	//}	
}

- (void) purchaseActionSound {
	// Create the product request and start it
	if (![UIDevice networkAvailable]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"You are not connected to the network!"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
		//[BuyBucksNode removeLoading];
	}
	else {/*
		featurePurchase=18;
		SKProductsRequest *preq = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_ID_SOUND]];
	    preq.delegate = self;
	    [preq start];*/
	}	
}
//////////////////////////////////ADDED NEW CODE FROM ORALLY//////////////////////////////

@end
