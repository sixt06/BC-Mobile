//
//  ConsoleViewController.m
//  BCMobile
//
//  Created by Hayoung Jeong on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScriptStorage.h"
#import "ConsoleViewController.h"
#import "BCWrapper.h"

@implementation ConsoleViewController
@synthesize textView;
@synthesize activityIndicator;
@synthesize scriptID;

- (void)loadView {
  [super loadView];

  // Toolbar setup
  UIBarButtonItem *flexSpaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

  UIBarButtonItem *clsItem = [[[UIBarButtonItem alloc] initWithTitle:@"Clear"
							       style:UIBarButtonItemStyleBordered
							      target:self
							      action:@selector(clear:)] autorelease];

  UIBarButtonItem *restartItem = [[[UIBarButtonItem alloc] initWithTitle:@"Restart"
							       style:UIBarButtonItemStyleBordered
							      target:self
							      action:@selector(start:)] autorelease];


  UIBarButtonItem *copyItem = [[[UIBarButtonItem alloc] initWithTitle:@"Copy"
								style:UIBarButtonItemStyleBordered
							       target:self
							       action:@selector(copy:)] autorelease];

  self.toolbarItems = [NSArray arrayWithObjects:flexSpaceItem, clsItem, restartItem, copyItem, flexSpaceItem, nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  storage = [[ScriptStorage alloc] init];

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

  [self start:nil];
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

  [super viewWillAppear:animated];
}

- (void)dealloc {
  [storage release];
  [bc release];

  [super dealloc];
}

#pragma mark - 
#pragma mark IBActions

- (IBAction)clear:(id)sender {
  textView.text = @"";
}

- (IBAction)start:(id)sender {
  NSDictionary *script = [storage script:scriptID];

  self.navigationItem.title = [NSString stringWithFormat:@"Running", [script objectForKey:@"title"]];

  [bc setDelegate:self];

  self.textView.editable = YES;

  [bc setLine:1];
  [bc execute:[script objectForKey:@"code"]];
}

- (IBAction)copy:(id)sender {
  UIPasteboard *pboard = [UIPasteboard generalPasteboard];
  [pboard setValue:textView.text
          forPasteboardType:@"public.utf8-plain-text"];
}

// - (IBAction)stop:(id)sender {
//   [bc stop];
// }

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
  [self.textView becomeFirstResponder];

  waitForInput = YES;
}

- (void)bcDidAcceptInput {
  waitForInput = NO;
}

- (void)bcDidStartExecution {
  [self.textView insertText:@"start script...\n"];

  [self.activityIndicator startAnimating];
  // UIBarButtonItem *stopButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)] autorelease];
  
  // self.navigationItem.rightBarButtonItem = stopButton;
}

- (void)bcDidFinishExecution {
  [self.textView insertText:@"\nfinished...\n"];
  [self.activityIndicator stopAnimating];

  self.textView.editable = NO;
  self.navigationItem.rightBarButtonItem = nil;
}

- (void)bcDidCancelExecution {
  [self.textView insertText:@"\ncanceled...\n"];
  self.textView.editable = NO;
  self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark -
#pragma mark Text view delegate methods

- (void)insertString:(NSString *)string {
  if ([string length] > 0) {
    NSRange range = textView.selectedRange;

    if (range.location == 0)
      range.location = [textView.text length];

    NSString *firstHalfString = @"";
    NSString *secondHalfString = @"";

    if ((range.location > 0) && (range.location <= [textView.text length]))
      firstHalfString = [textView.text substringToIndex:range.location];
    if ((range.location >= 0) && (range.location < [textView.text length]))
      secondHalfString = [textView.text substringFromIndex:range.location];

    textView.text = [NSString stringWithFormat: @"%@%@%@",
			      firstHalfString,
			      string,
			      secondHalfString];
  }
}

- (void)textViewDidChange:(UITextView *)_textView {
  static NSInteger location = -1;
  static NSInteger length = -1;
  NSRange range = textView.selectedRange;

  if (waitForInput) {
    if (length < 0) {
      location = range.location - 1;
      length = 1;
    } else {
      length = range.location - location;
    }
    
    if ([[_textView.text substringWithRange:NSMakeRange(range.location-1, 1)]
	  isEqual:@"\n"]) {
      [bc stdin:[_textView.text substringWithRange:NSMakeRange(location, length)]];
      location = -1;
      length = -1;
    }
    return;
  }
}

@end
