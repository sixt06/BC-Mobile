//
//  ScriptInfoViewController.m
//  BCMobile
//
//  Created by Hayoung Jeong on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScriptInfoViewController.h"


@implementation ScriptInfoViewController
@synthesize scriptID;
@synthesize scriptType;
@synthesize scriptCreated;
@synthesize scriptModified;
@synthesize scriptLoadOnStartup;
@synthesize scriptLocked;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
  [super viewDidLoad];

  storage = [[ScriptStorage alloc] init];

  self.navigationItem.title = @"Information";

  NSDictionary *script = [storage script:scriptID];

  self.scriptType.text = @"Script";

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setTimeStyle:NSDateFormatterMediumStyle];
  [formatter setDateStyle:NSDateFormatterMediumStyle];

  self.scriptCreated.text = [formatter stringFromDate:[script objectForKey:@"created"]];
  self.scriptModified.text = [formatter stringFromDate:[script objectForKey:@"modified"]];

  [formatter release];

  self.scriptLoadOnStartup.on = [[script objectForKey:@"loadOnStartup"] boolValue];
  self.scriptLocked.on = [[script objectForKey:@"locked"] boolValue];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
	  (interfaceOrientation == UIInterfaceOrientationLandscapeRight) ||
	  (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [storage release];
  [super dealloc];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)loadOnStartupDidChanged:(id)sender {
  NSMutableDictionary *script = [NSMutableDictionary dictionaryWithDictionary:[storage script:scriptID]];

  [script setObject:[NSNumber numberWithBool:self.scriptLoadOnStartup.on]
	     forKey:@"loadOnStartup"];

  [storage replaceScript:script forid:scriptID];
}

- (IBAction)lockedDidChanged:(id)sender {
  NSMutableDictionary *script = [NSMutableDictionary dictionaryWithDictionary:[storage script:scriptID]];

  [script setObject:[NSNumber numberWithBool:self.scriptLocked.on]
	     forKey:@"locked"];

  [storage replaceScript:script forid:scriptID];
}

@end
