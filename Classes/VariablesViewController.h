// -*- mode:objc -*-
//
//  VariablesViewController.h
//  BCMobile
//
//  Created by Hayoung Jeong on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCWrapper;

@interface VariablesViewController : UIViewController {
  UITextField *scaleTextField;
  UITextField *ibaseTextField;
  UITextField *obaseTextField;
  UIButton    *defaultButton;
  UIButton    *resetButton;
  BCWrapper   *bc;
}

@property (nonatomic, assign) IBOutlet UITextField *scaleTextField;
@property (nonatomic, assign) IBOutlet UITextField *ibaseTextField;
@property (nonatomic, assign) IBOutlet UITextField *obaseTextField;
@property (nonatomic, assign) IBOutlet UIButton    *defaultButton;
@property (nonatomic, assign) IBOutlet UIButton    *resetButton;

- (void)setBC:(BCWrapper *)_bc;
- (BCWrapper *)bc;

- (void)update;

- (IBAction)apply:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)setDefaults:(id)sender;

@end
