//
//  UITextView+UITextInput.m
//  BCMobile
//
//  Created by Hayoung Jeong on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UITextView+UITextInput.h"

@implementation UITextView (UITextInput)
- (void)insertText:(NSString *)theText {
  NSRange range = self.selectedRange;

  if ([self.text length] == 0) {
    self.text = theText;
    return;
  }

  NSString *firstHalfString = [self.text substringToIndex:range.location];
  NSString *secondHalfString = [self.text substringFromIndex:range.location];

  self.text = [NSString stringWithFormat: @"%@%@%@",
			firstHalfString,
			theText,
			secondHalfString];

  range.location += [theText length];
  self.selectedRange = range;

  NSLog(@"selectedRange = %ld", range.location);
}
 
- (void)deleteBackward {
  NSRange range = self.selectedRange;
  NSMutableString *_text = [self.text mutableCopy];

  if (range.location > 1) {
    NSRange location = NSMakeRange(range.location-1, 1);
    [_text deleteCharactersInRange:location];
    self.text = _text;
    [_text release];

    [self setNeedsDisplay];

    range.location--;
    self.selectedRange = range;
  }
}
@end
