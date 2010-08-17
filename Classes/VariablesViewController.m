//
//  VariablesViewController.m
//  BCMobile
//
//  Created by Hayoung Jeong on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VariablesViewController.h"
#import "BCWrapper.h"

@implementation VariablesViewController
@synthesize scaleTextField;
@synthesize ibaseTextField;
@synthesize obaseTextField;
@synthesize defaultButton;
@synthesize resetButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.title = @"Variables";
  [self update];
  [self.scaleTextField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
	  (interfaceOrientation == UIInterfaceOrientationLandscapeRight) ||
	  (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  if ((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || 
      (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)) {
    self.resetButton.frame = CGRectMake(350.0, 15.0, 103.0, 37.0);
    self.defaultButton.frame = CGRectMake(350.0, 60.0, 103.0, 37.0);
  } else {
    self.resetButton.frame = CGRectMake(117.0, 88.0, 72.0, 37.0);
    self.defaultButton.frame = CGRectMake(197.0, 88.0, 103.0, 37.0);
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [self.navigationController setNavigationBarHidden:NO
					   animated:YES];
  [self.navigationController setToolbarHidden:YES
				     animated:YES];

  if ((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || 
      (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)) {
    self.resetButton.frame = CGRectMake(350.0, 15.0, 103.0, 37.0);
    self.defaultButton.frame = CGRectMake(350.0, 60.0, 103.0, 37.0);
  } else {
    self.resetButton.frame = CGRectMake(117.0, 88.0, 72.0, 37.0);
    self.defaultButton.frame = CGRectMake(197.0, 88.0, 103.0, 37.0);
  }

  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self apply:nil];

  [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}

- (void)setBC:(BCWrapper *)_bc {
  bc = [_bc retain];
}

- (BCWrapper *)bc {
  return bc;
}

- (void)update {
  self.scaleTextField.text = [NSString stringWithFormat:@"%d", [bc scale]];
  self.ibaseTextField.text = [NSString stringWithFormat:@"%d", [bc ibase]];
  self.obaseTextField.text = [NSString stringWithFormat:@"%d", [bc obase]];
}

- (IBAction)apply:(id)sender {
  [bc setScale:[self.scaleTextField.text integerValue]];
  [bc setIbase:[self.ibaseTextField.text integerValue]];
  [bc setObase:[self.obaseTextField.text integerValue]];
}

- (IBAction)reset:(id)sender {
  NSUInteger _scale = [[NSUserDefaults standardUserDefaults] integerForKey:@"scale"];
  NSUInteger _ibase = [[NSUserDefaults standardUserDefaults] integerForKey:@"ibase"];
  NSUInteger _obase = [[NSUserDefaults standardUserDefaults] integerForKey:@"obase"];

  if (_scale == 0)
    _scale = 10;

  if (_ibase == 0)
    _ibase = 10;
  
  if (_obase == 0)
    _obase = 10;

  [bc setScale:_scale];
  [bc setIbase:_ibase];
  [bc setObase:_obase];

  [self update];
}

- (IBAction)setDefaults:(id)sender {
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithInteger:[self.scaleTextField.text integerValue]]
       forKey:@"scale"];
  [[NSUserDefaults standardUserDefaults]
    setObject:[NSNumber numberWithInteger:[self.ibaseTextField.text integerValue]]
       forKey:@"ibase"];
  [[NSUserDefaults standardUserDefaults]
    setObject:[NSNumber numberWithInteger:[self.obaseTextField.text integerValue]]
       forKey:@"obase"];

  [[NSUserDefaults standardUserDefaults] synchronize];

  [self reset:nil];
}

@end
