// -*- mode:objc -*-
//
//  ConsoleViewController.h
//  BCMobile
//
//  Created by Hayoung Jeong on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCWrapper.h"

@class ScriptStorage;

@interface ConsoleViewController : UIViewController <BCWrapperDelegate> {
  UITextView *textView;
  UIActivityIndicatorView *activityIndicator;

  ScriptStorage *storage;
  BCWrapper  *bc;

  NSInteger   scriptID;

  BOOL        doNotExecute;
  BOOL        waitForInput;
}

@property (nonatomic, assign) IBOutlet UITextView *textView;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign)          NSInteger   scriptID;

- (IBAction)clear:(id)sender;
- (IBAction)start:(id)sender;
- (IBAction)copy:(id)sender;

- (void)setBC:(BCWrapper *)_bc;
- (BCWrapper *)bc;

- (void)insertString:(NSString *)string;
- (void)textViewDidChange:(UITextView *)_textView;

@end
