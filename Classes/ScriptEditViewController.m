//
//  ScriptEditViewController.m
//  BCMobile
//
//  Created by Hayoung Jeong on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScriptStorage.h"
#import "ScriptEditViewController.h"
#import "ScriptInfoViewController.h"
#import "ScriptTitleViewController.h"
#import "ConsoleViewController.h"
#import "BCWrapper.h"

@implementation ScriptEditViewController

@synthesize codeView, scriptID;
@synthesize accessoryView;

- (void)loadView {
  [super loadView];

  // Toolbar setup
  UIBarButtonItem *flexSpaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

  UIBarButtonItem *infoItem = [[[UIBarButtonItem alloc] initWithTitle:@"Information"
								style:UIBarButtonItemStyleBordered
							       target:self
							       action:@selector(showInfo:)] autorelease];

  UIBarButtonItem *renameItem = [[[UIBarButtonItem alloc] initWithTitle:@"Rename"
								  style:UIBarButtonItemStyleBordered
								 target:self
								 action:@selector(rename:)] autorelease];

  UIBarButtonItem *executeItem = [[[UIBarButtonItem alloc] initWithTitle:@"Execute"
								   style:UIBarButtonItemStyleBordered
								  target:self
								  action:@selector(execute:)] autorelease];

  self.toolbarItems = [NSArray arrayWithObjects:flexSpaceItem, infoItem, renameItem, executeItem, flexSpaceItem, nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  storage = [[ScriptStorage alloc] init];

  if (scriptID < 0) {
    [self.codeView becomeFirstResponder];
  } else {
    // read script information
    NSDictionary *script = [storage script:scriptID];

    self.codeView.text = [script objectForKey:@"code"];
    self.navigationItem.title = [script objectForKey:@"title"];

    if ([[script objectForKey:@"locked"] boolValue]) {
      self.codeView.editable = NO;
    }
  }

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

  [[NSNotificationCenter defaultCenter]
    removeObserver:self
	      name:nil
	    object:nil];

  [self save:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  // re-read script information
  NSDictionary *script = [storage script:scriptID];

  self.navigationItem.title = [script objectForKey:@"title"];

  [super viewWillAppear:animated];
}

- (void)dealloc {
  [storage release];
  [bc release];

  [super dealloc];
}

- (void)setBC:(BCWrapper *)_bc {
  bc = [_bc retain];
}

- (BCWrapper *)bc {
  return bc;
}

#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
    
  NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];

  CGRect keyboardRect = [aValue CGRectValue];
  keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
  CGFloat keyboardTop = keyboardRect.origin.y;
  CGRect newViewFrame = self.view.bounds;
  newViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
  NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval animationDuration;
  [animationDurationValue getValue:&animationDuration];
    
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:animationDuration];
    
  codeView.frame = newViewFrame;
  [codeView scrollRectToVisible:codeView.frame animated:YES];

  [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
  NSDictionary* userInfo = [notification userInfo];
    
  NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval animationDuration;
  [animationDurationValue getValue:&animationDuration];
    
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:animationDuration];
    
  codeView.frame = self.view.bounds;
    
  [UIView commitAnimations];
}

- (void)editStart {
  UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)] autorelease];

  self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)editDone {
  self.navigationItem.rightBarButtonItem = nil;
}

- (void)showInfo:(id)sender {
  ScriptInfoViewController *detailViewController = [[ScriptInfoViewController alloc] initWithNibName:@"ScriptInfoViewController" bundle:nil];

  detailViewController.scriptID = scriptID;

  [self.navigationController pushViewController:detailViewController
				       animated:YES];
  [detailViewController release];
}

- (void)save:(id)sender {
  NSMutableDictionary *script = [NSMutableDictionary dictionaryWithDictionary:[storage script:scriptID]];

  [script setObject:[NSDate date] forKey:@"modified"];
  [script setObject:self.codeView.text forKey:@"code"];

  [storage replaceScript:script forid:scriptID];

  [self editDone];
  
  if ([codeView isFirstResponder])
    [codeView resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
  if (codeView.inputAccessoryView == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"ScriptEditAccessoryView"
				  owner:self
				options:nil];
    codeView.inputAccessoryView = accessoryView;    
    self.accessoryView = nil;
  }

  return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
  [self editStart];
}

- (void)insertString:(NSString *)string {
  if ([string length] > 0) {
    NSRange range = codeView.selectedRange;

    if (range.location == 0)
      range.location = [codeView.text length];

    NSString *firstHalfString = @"";
    NSString *secondHalfString = @"";

    if ((range.location > 0) && (range.location <= [codeView.text length]))
      firstHalfString = [codeView.text substringToIndex:range.location];
    if ((range.location >= 0) && (range.location < [codeView.text length]))
      secondHalfString = [codeView.text substringFromIndex:range.location];

    codeView.text = [NSString stringWithFormat: @"%@%@%@",
			      firstHalfString,
			      string,
			      secondHalfString];
  }
}

- (IBAction)rename:(id)sender {
  ScriptTitleViewController *detailViewController = [[ScriptTitleViewController alloc] initWithNibName:@"ScriptTitleViewController" bundle:nil];
  detailViewController.scriptID = self.scriptID;

  [self.navigationController pushViewController:detailViewController
			  animated:YES];

  [detailViewController release];
}

- (IBAction)execute:(id)sender {
  ConsoleViewController *detailViewController = [[ConsoleViewController alloc] initWithNibName:@"ConsoleViewController" bundle:nil];

  detailViewController.scriptID = self.scriptID;
  [detailViewController setBC:[self bc]];

  [self.navigationController pushViewController:detailViewController
				       animated:YES];
  [detailViewController release];
}

- (IBAction)insertLParen:(id)sender {
  [self insertString:@"("];
}

- (IBAction)insertRParen:(id)sender {
  [self insertString:@")"];
}

- (IBAction)insertLCBrace:(id)sender {
  [self insertString:@"{"];
}

- (IBAction)insertRCBrace:(id)sender {
  [self insertString:@"}"];
}

- (IBAction)insertSemiColon:(id)sender {
  [self insertString:@";"];
}

- (IBAction)insertGT:(id)sender {
  [self insertString:@">"];
}

- (IBAction)insertLT:(id)sender {
  [self insertString:@"<"];
}

- (IBAction)insertEQ:(id)sender {
  [self insertString:@"="];
}

- (IBAction)insertPlus:(id)sender {
  [self insertString:@"+"];
}

- (IBAction)insertMinus:(id)sender {
  [self insertString:@"-"];
}

- (IBAction)insertMultiple:(id)sender {
  [self insertString:@"*"];
}

- (IBAction)insertDivision:(id)sender {
  [self insertString:@"/"];
}

@end
