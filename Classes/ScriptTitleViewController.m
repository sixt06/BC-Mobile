//
//  ScriptTitleViewController.m
//  BCMobile
//
//  Created by Hayoung Jeong on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScriptTitleViewController.h"
#import "ScriptStorage.h"

@implementation ScriptTitleViewController
@synthesize textField;
@synthesize scriptID;

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.title = @"Change name";
  storage = [[ScriptStorage alloc] init];

  if (scriptID >= 0) {
    
    NSMutableDictionary *script = [NSMutableDictionary dictionaryWithDictionary:[storage script:scriptID]];

    self.textField.text = [script objectForKey:@"title"];
  }

  [textField becomeFirstResponder];
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

- (IBAction)OK:(id)sender {
  if ([textField.text length] == 0) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid title"
						    message:nil
						   delegate:self
					  cancelButtonTitle:@"Cancel"
					  otherButtonTitles:nil];
    [alert show];

    return;
  }

  if (scriptID >= 0) {
    // rename
    NSMutableDictionary *script = [NSMutableDictionary dictionaryWithDictionary:[storage script:scriptID]];
    [script setObject:textField.text forKey:@"title"];
    [storage replaceScript:script forid:scriptID];
  } else {
    // compose new script
    NSDictionary *newItem = [NSDictionary dictionaryWithObjectsAndKeys:textField.text, @"title", [NSDate date], @"created", [NSDate date], @"modified", [NSNumber numberWithBool:NO], @"loadOnStartup", @"", @"code", nil];
    
    [storage addScript:newItem];
  }

  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

@end
