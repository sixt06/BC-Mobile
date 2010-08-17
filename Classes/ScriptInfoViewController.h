// -*- mode:objc -*-
//
//  ScriptInfoViewController.h
//  BCMobile
//
//  Created by Hayoung Jeong on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScriptStorage;

@interface ScriptInfoViewController : UIViewController {
  ScriptStorage *storage;
  NSInteger  scriptID;

  UILabel   *scriptType;
  UILabel   *scriptCreated;
  UILabel   *scriptModified;
  UISwitch  *scriptLoadOnStartup;
  UISwitch  *scriptLocked;
}

@property (nonatomic, assign)          NSInteger  scriptID;
@property (nonatomic, assign) IBOutlet UILabel   *scriptType;
@property (nonatomic, assign) IBOutlet UILabel   *scriptCreated;
@property (nonatomic, assign) IBOutlet UILabel   *scriptModified;
@property (nonatomic, assign) IBOutlet UISwitch  *scriptLoadOnStartup;
@property (nonatomic, assign) IBOutlet UISwitch  *scriptLocked;

- (IBAction)loadOnStartupDidChanged:(id)sender;
- (IBAction)lockedDidChanged:(id)sender;

@end
