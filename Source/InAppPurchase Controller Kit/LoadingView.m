//
//  LoadingView.m
//  ITIW
//
//  Created by itiw on 1/4/11.
//  Copyright 2011 ITIW. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

CGPathRef NewPathWithRoundRect(CGRect rect, CGFloat cornerRadius)
{
	//
	// Create the boundary path
	//
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,
					  rect.origin.x,
					  rect.origin.y + rect.size.height - cornerRadius);
	
	// Top left corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x,
						rect.origin.y,
						rect.origin.x + rect.size.width,
						rect.origin.y,
						cornerRadius);
	
	// Top right corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x + rect.size.width,
						rect.origin.y,
						rect.origin.x + rect.size.width,
						rect.origin.y + rect.size.height,
						cornerRadius);
	
	// Bottom right corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x + rect.size.width,
						rect.origin.y + rect.size.height,
						rect.origin.x,
						rect.origin.y + rect.size.height,
						cornerRadius);
	
	// Bottom left corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x,
						rect.origin.y + rect.size.height,
						rect.origin.x,
						rect.origin.y,
						cornerRadius);
	
	// Close the path at the rounded rect
	CGPathCloseSubpath(path);
	
	return path;
}

@implementation LoadingView
@synthesize delegate;
//
// loadingViewInView:
//
// Constructor for this view. Creates and adds a loading view for covering the
// provided aSuperview.
//
// Parameters:
//    aSuperview - the superview that will be covered by the loading view
//
// returns the constructed view, already added as a subview of the aSuperview
//	(and hence retained by the superview)
//
+ (id)loadingViewInView:(UIView *)aSuperview {
    
	LoadingView *loadingView = [[[LoadingView alloc] initWithFrame:[aSuperview bounds]] autorelease];
    [loadingView loadElements];
	if (!loadingView)
		return nil;
	
	loadingView.opaque = NO;
	loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[aSuperview addSubview:loadingView];
	
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
	
	return loadingView;
}

- (void)loadElements {
    const CGFloat DEFAULT_LABEL_WIDTH = 280.0f;
    const CGFloat DEFAULT_LABEL_HEIGHT = 25.0f;
    CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
    
    loadingLabel = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
    loadingLabel.text = NSLocalizedString(@"Loading...", nil);
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textAlignment = UITextAlignmentCenter;
    loadingLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:loadingLabel];
    
    
    activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    [self addSubview:activityIndicatorView];
    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |	UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [activityIndicatorView startAnimating];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    activityIndicatorView.frame = CGRectMake(winSize.width/2-activityIndicatorView.frame.size.width/2, winSize.height/2-activityIndicatorView.frame.size.height/2, activityIndicatorView.frame.size.width, activityIndicatorView.frame.size.height);
    loadingLabel.frame = CGRectMake(winSize.width/2-loadingLabel.frame.size.width/2, activityIndicatorView.frame.origin.y+activityIndicatorView.frame.size.height, loadingLabel.frame.size.width, loadingLabel.frame.size.height);
}

-(void) loadCrossButton {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    UIImage *crossImg = [UIImage imageNamed:@"btn-cross-loading.png"];
	UIButton *btnCross = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [btnCross setImage:crossImg forState:UIControlStateNormal];
    btnCross.frame = CGRectMake(winSize.width/2-crossImg.size.width/2, loadingLabel.frame.origin.y+loadingLabel.frame.size.height, crossImg.size.width, crossImg.size.height);
	btnCross.bounds = CGRectMake(0, 0, crossImg.size.width, crossImg.size.height);
	[btnCross addTarget:self action:@selector(crossCallBack:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:btnCross];
}

-(void)crossCallBack:(id)sender {
    [self performSelector:@selector(removeView)];
    if(delegate && [delegate respondsToSelector:@selector(loadingDidCanceled)]) {
        [delegate loadingDidCanceled];
    }
}

//
// removeView
//
// Animates the view out from the superview. As the view is removed from the
// superview, it will be released.
//
- (void)removeView
{
	UIView *aSuperview = [self superview];
	[super removeFromSuperview];
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
}

//
// drawRect:
//
// Draw the view.
//
- (void)drawRect:(CGRect)rect
{
	rect.size.height -= 1;
	rect.size.width -= 1;
	
	const CGFloat RECT_PADDING = 8.0f;
	rect = CGRectInset(rect, RECT_PADDING, RECT_PADDING);
	
	const CGFloat ROUND_RECT_CORNER_RADIUS = 5.0f;
	CGPathRef roundRectPath = NewPathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat BACKGROUND_OPACITY = 0.6f;
	CGFloat STROKE_OPACITY = 0.25f;
	
	/*if([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound && appDelegate.isiPadAllowed)
     {
     BACKGROUND_OPACITY = 0.0f;
     STROKE_OPACITY = 0.0f;
     }*/
	
	CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);
	
	CGContextSetRGBStrokeColor(context, 1, 1, 1, STROKE_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextStrokePath(context);
	
	CGPathRelease(roundRectPath);
}

//
// dealloc
//
// Release instance memory.
//
- (void)dealloc
{
    [super dealloc];
}

@end
