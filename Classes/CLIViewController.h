// -*- mode:objc -*-
//
//  CLIViewController.h
//  BCMobile
//
//  Created by Hayoung Jeong on 4/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCWrapper.h"

@class HelpViewController;
@class ScriptTableViewController;
@class VariablesViewController;

@interface CLIViewController : UIViewController <BCWrapperDelegate> {
  UITextView                *textView;
  UIView                    *accessoryView;
  UIActivityIndicatorView   *activityIndicator;
  HelpViewController        *helpViewController;
  ScriptTableViewController *scriptTableViewController;
  VariablesViewController   *variablesViewController;
  BCWrapper                 *bc;

  BOOL                       doNotExecute;
  BOOL                       waitForInput;
}

@property (nonatomic, assign) IBOutlet UITextView              *textView;
@property (nonatomic, assign) IBOutlet UIView                  *accessoryView;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) HelpViewController               *helpViewController;
@property (nonatomic, assign) ScriptTableViewController        *scriptTableViewController;
@property (nonatomic, assign) VariablesViewController          *variablesViewController;

- (void)setBC:(BCWrapper *)_bc;
- (BCWrapper *)bc;

- (void)insertString:(NSString *)string;

// accessoryView action
- (IBAction)script:(id)sender;
- (IBAction)help:(id)sender;
- (IBAction)variables:(id)sender;
- (IBAction)clearScreen:(id)sender;
- (IBAction)lastVar:(id)sender;
- (IBAction)openParen:(id)sender;
- (IBAction)closeParen:(id)sender;
- (IBAction)plusSymbol:(id)sender;
- (IBAction)minSymbol:(id)sender;
- (IBAction)mulSymbol:(id)sender;
- (IBAction)divSymbol:(id)sender;

- (NSString *)promptString;
- (void)showPrompt;

@end
