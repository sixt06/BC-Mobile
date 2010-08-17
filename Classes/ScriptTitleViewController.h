// -*- mode:objc -*-
//
//  ScriptTitleViewController.h
//  BCMobile
//
//  Created by Hayoung Jeong on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScriptStorage;

@interface ScriptTitleViewController : UIViewController {
  UITextField *textField;
  NSInteger    scriptID;
  ScriptStorage *storage;
}

@property (nonatomic, assign) IBOutlet UITextField *textField;
@property (nonatomic, assign) NSInteger scriptID;

- (IBAction)OK:(id)sender;
- (IBAction)cancel:(id)sender;

@end
