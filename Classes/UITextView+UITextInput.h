// -*- mode:objc -*-
//
//  UITextView+UITextInput.h
//  BCMobile
//
//  Created by Hayoung Jeong on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITextView (UITextInput)
- (void)insertText:(NSString *)theText;
- (void)deleteBackward;
@end
