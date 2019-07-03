    //
//  DTTwoPageViewController.m
//  DTPinLockController
//
//  Created by Oliver Drobnik on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DTTwoPageViewController.h"


@implementation DTTwoPageViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	// create base view
	CGRect rect = [[UIScreen mainScreen] bounds];
	UIView *view = [[UIView alloc] initWithFrame:rect];

	// first page
	firstPageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
	firstPageView.backgroundColor = [UIColor clearColor];
	firstPageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[view addSubview:firstPageView];
	
	// second page
	rect.origin.x = rect.origin.x + rect.size.width;
	secondPageView = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width, 0, rect.size.width, rect.size.height)];
	secondPageView.backgroundColor = [UIColor clearColor];
	secondPageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[view addSubview:secondPageView];
	
	// watch base view frame
	[view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
	
	self.view = view;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)dealloc 
{
	[self.view removeObserver:self forKeyPath:@"frame"];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"frame"]) 
	{
		CGRect rect = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
		
		firstPageView.frame = CGRectMake(-currentIndex * rect.size.width, 0, rect.size.width, rect.size.height);
		secondPageView.frame = CGRectMake((1-currentIndex)*rect.size.width, 0, rect.size.width, rect.size.height);
    }
}

#pragma mark Page Switching
- (void) switchToPageAtIndex:(NSInteger)index animated:(BOOL)animated
{
	if (currentIndex==index)
	{
		return;
	}
	
	currentIndex = index;
	
	if (animated)
	{
		[UIView beginAnimations:nil context:nil];
	}
	
	CGRect rect = self.view.bounds;
	
	firstPageView.frame = CGRectMake(-index * rect.size.width, 0, rect.size.width, rect.size.height);
	secondPageView.frame = CGRectMake((1-index)*rect.size.width, 0, rect.size.width, rect.size.height);
	
	if (animated)
	{
		[UIView commitAnimations];
	}
}

@synthesize firstPageView;
@synthesize secondPageView;

@end
