//
//  CLIViewController.m
//  BCMobile
//
//  Created by Hayoung Jeong on 4/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CLIViewController.h"
#import "HelpViewController.h"
#import "ScriptTableViewController.h"
#import "VariablesViewController.h"
#import "BCWrapper.h"

@implementation CLIViewController

@synthesize textView;
@synthesize accessoryView;
@synthesize activityIndicator;
@synthesize helpViewController;
@synthesize scriptTableViewController;
@synthesize variablesViewController;

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationController.navigationBarHidden = YES;
  self.navigationController.toolbarHidden = YES;
  self.navigationItem.title = @"CLI Mode";

  [[NSNotificationCenter defaultCenter]
    addObserver:self
       selector:@selector(keyboardWillShow:)
	   name:UIKeyboardWillShowNotification
	 object:nil];

  [[NSNotificationCenter defaultCenter]
    addObserver:self
       selector:@selector(keyboardWillHide:)
	   name:UIKeyboardWillHideNotification
	 object:nil];

  [bc setDelegate:self];
  [bc welcome];
  [self showPrompt];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
	  (interfaceOrientation == UIInterfaceOrientationLandscapeRight) ||
	  (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  [super viewDidUnload];

  [bc release];

  [[NSNotificationCenter defaultCenter]
    removeObserver:self
	      name:nil
	    object:nil];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter]
    removeObserver:self
	      name:nil
	    object:nil];

  [helpViewController release];
  [scriptTableViewController release];

  [super dealloc];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  if ((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || 
      (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)) {
    self.activityIndicator.frame = CGRectMake(221.5, 30.0, 37.0, 37.0);
  } else {
    self.activityIndicator.frame = CGRectMake(141.5, 80.0, 37.0, 37.0);
  }
}

- (void)viewWillAppear:(BOOL)animated {
  if ((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || 
      (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)) {
    self.activityIndicator.frame = CGRectMake(221.5, 30.0, 37.0, 37.0);
  } else {
    self.activityIndicator.frame = CGRectMake(141.5, 80.0, 37.0, 37.0);
  }

  [self.navigationController setNavigationBarHidden:YES
					   animated:YES];
  [self.navigationController setToolbarHidden:YES
				     animated:YES];

  [super viewWillAppear:animated];

  [bc setDelegate:self];

  // Make the keyboard appear when the application launches.
  [textView becomeFirstResponder];
}

#pragma mark -
#pragma mark Text view delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
  if (textView.inputAccessoryView == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"AccessoryView"
				  owner:self
				options:nil];
    textView.inputAccessoryView = accessoryView;    
    self.accessoryView = nil;
  }

  return YES;
}

- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  NSInteger last = [_textView.text length];

  if ((range.length == 1) && ([text length] == 0)) {
    // prevent delete string
    NSString *lastChar = [_textView.text substringWithRange:NSMakeRange(last-[[self promptString] length], [[self promptString] length])];
    if([lastChar isEqual:[self promptString]])
      return NO;
  } 

  return YES;
}


- (void)textViewDidChange:(UITextView *)_textView {
  NSRange range = _textView.selectedRange;

  if (doNotExecute) {
    doNotExecute = NO;
    return;
  } 

  NSArray *lines = [_textView.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

  if ([lines count]) {
    if ([[lines lastObject] length] == 0) {
      NSString *lastCommandLine = [lines objectAtIndex:([lines count] - 2)];
      if (waitForInput) {
	[bc stdin:[NSString stringWithFormat:@"%@\n", lastCommandLine]];
      } else {
	NSArray *removePrefix = [lastCommandLine componentsSeparatedByString:[self promptString]];
	NSString *command = [NSString stringWithFormat:@"%@\n", [removePrefix lastObject]];

	[bc setLine:0];
	[bc execute:command];
      }
    }
  }
}

#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
    
  NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];

  CGRect keyboardRect = [aValue CGRectValue];
  keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
  CGFloat keyboardTop = keyboardRect.origin.y;
  CGRect newTextViewFrame = self.view.bounds;
  newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
  NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval animationDuration;
  [animationDurationValue getValue:&animationDuration];
    
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:animationDuration];
    
  textView.frame = newTextViewFrame;

  [UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
  NSDictionary* userInfo = [notification userInfo];
    
  NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval animationDuration;
  [animationDurationValue getValue:&animationDuration];
    
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:animationDuration];
    
  textView.frame = self.view.bounds;
    
  [UIView commitAnimations];
}

#pragma mark -
#pragma mark bc delegate

- (void)setBC:(BCWrapper *)_bc {
  bc = [_bc retain];
}

- (BCWrapper *)bc {
  return bc;
}

- (void)bcDidPutCharacter:(NSString *)string {
  [self.textView insertText:string];
}

- (void)bcDidWaitForInput {
  waitForInput = YES;
}

- (void)bcDidAcceptInput {
  waitForInput = NO;
}

- (void)bcDidStartExecution {
  [self.activityIndicator startAnimating];
}

- (void)bcDidFinishExecution {
  [self.activityIndicator stopAnimating];
  [self showPrompt];
}

#pragma mark -
#pragma mark Accessory view action

- (IBAction)script:(id)sender {
  // hide keyboard
  [textView resignFirstResponder];

  // create help view controller
  if (!scriptTableViewController) {
    scriptTableViewController = [[ScriptTableViewController alloc] initWithNibName:@"ScriptTableViewController" bundle:nil];
    [scriptTableViewController setBC:[self bc]];
  }

  [self.navigationController pushViewController:scriptTableViewController
				       animated:YES];
}

- (IBAction)help:(id)sender {
  // hide keyboard
  [textView resignFirstResponder];

  // create help view controller
  if (!helpViewController)
    helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];

  [self.navigationController pushViewController:helpViewController
				       animated:YES];
}

- (IBAction)variables:(id)sender {
  // create variable view controller
  if (!variablesViewController) {
    variablesViewController = [[VariablesViewController alloc] initWithNibName:@"VariablesViewController" bundle:nil];
    [variablesViewController setBC:[self bc]];
  }

  [self.navigationController pushViewController:variablesViewController
				       animated:YES];  
}

- (IBAction)clearScreen:(id)sender {
  textView.text = @"";
  [self showPrompt];
}

- (IBAction)lastVar:(id)sender {
  [self.textView insertText:@"last"];
}

- (IBAction)openParen:(id)sender {
  [self.textView insertText:@"("];
}

- (IBAction)closeParen:(id)sender {
  [self.textView insertText:@")"];
}

- (IBAction)plusSymbol:(id)sender {
  [self.textView insertText:@"+"];
}

- (IBAction)minSymbol:(id)sender {
  [self.textView insertText:@"-"];
}

- (IBAction)mulSymbol:(id)sender {
  [self.textView insertText:@"*"];
}

- (IBAction)divSymbol:(id)sender {
  [self.textView insertText:@"/"];
}

#pragma mark -
#pragma mark text view action

- (NSString *)promptString {
  return @"> ";
}

- (void)showPrompt {
  [self.textView insertText:[self promptString]];
}

@end
