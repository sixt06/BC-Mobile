// -*- mode:objc -*-
//
//  ScriptEditViewController.h
//  BCMobile
//
//  Created by Hayoung Jeong on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScriptStorage;
@class BCWrapper;

@interface ScriptEditViewController : UIViewController {
  NSInteger     scriptID;
  UIView       *accessoryView;
  UITextView   *codeView;
  
  ScriptStorage *storage;
  BCWrapper    *bc;
}

@property (nonatomic, assign) IBOutlet UITextView   *codeView;
@property (nonatomic, assign) IBOutlet UIView       *accessoryView;
@property (nonatomic, assign)          NSInteger     scriptID;

- (void)setBC:(BCWrapper *)_bc;
- (BCWrapper *)bc;

- (void)editStart;
- (void)editDone;
- (void)showInfo:(id)sender;
- (void)save:(id)sender;

- (IBAction)rename:(id)sender;
- (IBAction)execute:(id)sender;

- (IBAction)insertLParen:(id)sender;
- (IBAction)insertRParen:(id)sender;
- (IBAction)insertLCBrace:(id)sender;
- (IBAction)insertRCBrace:(id)sender;
- (IBAction)insertSemiColon:(id)sender;
- (IBAction)insertGT:(id)sender;
- (IBAction)insertLT:(id)sender;
- (IBAction)insertEQ:(id)sender;
- (IBAction)insertPlus:(id)sender;
- (IBAction)insertMinus:(id)sender;
- (IBAction)insertMultiple:(id)sender;
- (IBAction)insertDivision:(id)sender;

@end
