// -*- mode:objc -*-
//
//  ScriptTableViewController.h
//  BCMobile
//
//  Created by Hayoung Jeong on 5/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScriptStorage;
@class BCWrapper;

@interface ScriptTableViewController : UITableViewController {
  ScriptStorage *storage;
  BCWrapper *bc;
}


- (void)setBC:(BCWrapper *)_bc;
- (BCWrapper *)bc;

- (IBAction)compose:(id)sender;
- (IBAction)rename:(id)sender;
- (IBAction)execute:(id)sender;

@end
