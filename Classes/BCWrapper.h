// -*- mode:objc -*-
//
//  BCWrapper.h
//  iBC
//
//  Created by Ha-young Jeong on 12/30/09.
//  Copyright 2009 Donut System LSI. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BCWrapperDelegate;

@interface BCWrapper : NSObject {
  id <BCWrapperDelegate> _delegate;
  NSThread *_worker;

  NSMutableString *_stdoutBuffer;
  NSMutableString *_stdinBuffer;
}

- (void)welcome;

// delegate
- (void)setDelegate:(id)sender;

// execution
- (void)execute:(NSString *)string;
- (void)stop;
- (void)stdin:(NSString *)string;

// ibase, obase, scale
- (void)setIbase:(NSInteger)base;
- (NSInteger)ibase;
- (void)setObase:(NSInteger)base;
- (NSInteger)obase;
- (void)setScale:(NSInteger)number;
- (NSInteger)scale;

// line number
- (void)setLine:(NSInteger)line;

- (NSMutableString *)stdinBuffer;
- (void)setStdinBuffer:(NSString *)string;
- (NSMutableString *)stdoutBuffer;
- (void)setStdoutBuffer:(NSString *)string;
- (void)flush;

@end

@protocol BCWrapperDelegate <NSObject>
@optional

// standard, error, and warnning output
- (void)bcDidPutCharacter:(NSString *)string;

// standard input
- (void)bcDidWaitForInput;
- (void)bcDidAcceptInput;

// Execution
- (void)bcDidStartExecution;
- (void)bcDidFinishExecution;
- (void)bcDidCancelExecution;

@end
