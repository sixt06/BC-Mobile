//
//  BCWrapper.m
//  iBC
//
//  Created by Ha-young Jeong on 12/30/09.
//  Copyright 2009 Donut System LSI. All rights reserved.
//

#import "BCWrapper.h"
#import "ScriptStorage.h"
#import "../bc/bcdefs.h"
#import "../bc/global.h"
#import "../bc/proto.h"

@interface BCWrapper (Internal)
- (void)setup;
- (void)loadLibmath;
- (void)parse:(NSString *)string;
@end

@implementation BCWrapper

#define BCM_VERSION "2.0"

// bc c-to-obj bridge
extern pthread_mutex_t bc_input_buf_mutex;
extern char bc_getchar_buf;
extern int i_base;
extern int o_base;
extern int scale;
extern int compile_only;
extern int line_no;

void warranty(char *prefix);
void bc_ignore_warning(int value);
void *pObject;

- (id)init {
  if (self = [super init]) {
    init_storage();
    init_load();
    init_tree();
    init_gen();

    compile_only = NO;

    [self loadLibmath];
    [self setup];
  }

  return self;
}

- (void)loadLibmath {
  /* Load the code from a precompiled version of the math libarary. */
  extern char *libmath[];
  char **mstr;
  char tmp;
  /* These MUST be in the order of first mention of each function.
     That is why "a" comes before "c" even though "a" is defined after
     after "c".  "a" is used in "s"! */
  tmp = lookup ("e", FUNCT);
  tmp = lookup ("l", FUNCT);
  tmp = lookup ("s", FUNCT);
  tmp = lookup ("a", FUNCT);
  tmp = lookup ("c", FUNCT);
  tmp = lookup ("j", FUNCT);
  mstr = libmath;
  while (*mstr) {
    load_code (*mstr);
    mstr++;
  }
}

- (void)setup {
  bc_ignore_warning(YES);

  // load user specific codes
  ScriptStorage *storage = [[ScriptStorage alloc] init];

  NSArray *scripts = [storage scripts];
  for (id script in scripts) {
    if ([[script objectForKey:@"loadOnStartup"] boolValue]) {
      NSString *code = [script objectForKey:@"code"];
      
      if ([code length]) {
	[self parse:code];
      }
    }
  }

  [storage release];

  NSUInteger _scale = [[NSUserDefaults standardUserDefaults] integerForKey:@"scale"];
  NSUInteger _ibase = [[NSUserDefaults standardUserDefaults] integerForKey:@"ibase"];
  NSUInteger _obase = [[NSUserDefaults standardUserDefaults] integerForKey:@"obase"];

  if (_scale)
    [self setScale:_scale];

  if (_ibase)
    [self setIbase:_ibase];
  
  if (_obase)
    [self setObase:_obase];

  BOOL ignoreWarn  = [[NSUserDefaults standardUserDefaults] boolForKey:@"ignoreWarning"];
 
  bc_ignore_warning(ignoreWarn);

  pthread_mutex_init(&bc_input_buf_mutex, NULL);
  pObject = self;
}

- (void)welcome {
  show_bc_version();
  welcome();
  
  [[self stdoutBuffer] appendString:[NSString stringWithFormat:@"(scale=%d, ibase=%d, obase=%d)\n", [self scale], [self ibase], [self obase], nil]];
  
  [self flush];
}

- (void)execute:(NSString *)string {
  if ([_worker isCancelled]) {
    [_worker release];
    _worker = nil;
  } else if ([_worker isExecuting])
    return;

  [_worker release];

  NSString *command;
  if ([string hasSuffix:@"\n"])
    command = string;
  else 
    command = [NSString stringWithFormat:@"%@\n", string];

  _worker = [[NSThread alloc] initWithTarget:self
				    selector:@selector(executionThread:)
				      object:command];
  [_worker setName:@"bcWorker"];
  [_worker start];
}

- (void)stop {
  if (![_worker isExecuting]) 
    return;

  [_worker cancel];

  if ([_delegate respondsToSelector:@selector(bcDidCancelExecution)])
    [(NSObject *)_delegate performSelectorOnMainThread:@selector(bcDidCancelExecution)
				withObject:nil
			     waitUntilDone:YES];
}

- (void)executionThread:(NSString *)string {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  if ([_delegate respondsToSelector:@selector(bcDidStartExecution)])
    [(NSObject *)_delegate performSelectorOnMainThread:@selector(bcDidStartExecution)
				  withObject:nil
			       waitUntilDone:YES];

    [self parse:string];

    [self performSelectorOnMainThread:@selector(flush)
			   withObject:nil
			waitUntilDone:YES];

    if ([_delegate respondsToSelector:@selector(bcDidFinishExecution)])
      [(NSObject *)_delegate performSelectorOnMainThread:@selector(bcDidFinishExecution)
				  withObject:nil
			       waitUntilDone:YES];

  [pool release];
}

- (void)parse:(NSString *)string {
  const char *cString = [string cStringUsingEncoding:NSASCIIStringEncoding];

  struct yy_buffer_state *bc_buf = yy_scan_string(cString);
  init_gen ();
  yyparse();
  run_code();
  yy_delete_buffer(bc_buf);
}

// standard input
- (void)stdin:(NSString *)string {
  char *cString = [string UTF8String];
  bc_getchar_buf = cString[0];

  if ([string length] > 1)
    [self setStdinBuffer:[string substringFromIndex:1]];

  pthread_mutex_unlock(&bc_input_buf_mutex);
}

- (void)setDelegate:(id)sender {
  _delegate = sender;
}

- (void)setIbase:(NSInteger)base {
  i_base = base;
}

- (NSInteger)ibase {
  return i_base;
}

- (void)setObase:(NSInteger)base {
  o_base = base;
}

- (NSInteger)obase {
  return o_base;
}

- (void)setScale:(NSInteger)number {
  scale = number;
}

- (NSInteger)scale {
  return scale;
}

- (void)setLine:(NSInteger)line {
  line_no = line;
}

- (NSMutableString *)stdinBuffer {
  if (!_stdinBuffer) {
    _stdinBuffer = [[NSMutableString alloc] init];
  }

  return _stdinBuffer;
}

- (void)setStdinBuffer:(NSString *)string {
  [_stdinBuffer setString:string];
}

- (NSMutableString *)stdoutBuffer {
  if (!_stdoutBuffer) {
    _stdoutBuffer = [[NSMutableString alloc] init];
  }

  return _stdoutBuffer;  
}

- (void)setStdoutBuffer:(NSString *)string {
  [_stdoutBuffer setString:string];
}

- (void)flush {
  if ([_delegate respondsToSelector:@selector(bcDidPutCharacter:)])
    [(NSObject *)_delegate performSelectorOnMainThread:@selector(bcDidPutCharacter:)
					    withObject:[self stdoutBuffer]
					 waitUntilDone:YES];  
  [self setStdoutBuffer:@""];
}

- (void)bcDidPutCharacter:(char)ch {
  [[self stdoutBuffer] appendString:[NSString stringWithFormat:@"%c", ch]];
}

- (void)bcWillWaitForInput {
  if ([[self stdinBuffer] length] > 0) {
    char *cString = [[self stdinBuffer] UTF8String];

    bc_getchar_buf = cString[0];

    if ([[self stdinBuffer] length] > 1)
      [self setStdinBuffer:[[self stdinBuffer] substringFromIndex:1]];
    else
      [self setStdinBuffer:@""];

    pthread_mutex_unlock(&bc_input_buf_mutex);
  } else {
    // wait for input
    pthread_mutex_lock(&bc_input_buf_mutex);

    if ([_delegate respondsToSelector:@selector(bcDidWaitForInput)])
      [(NSObject *)_delegate performSelectorOnMainThread:@selector(bcDidWaitForInput)
					      withObject:nil
					   waitUntilDone:YES];
  }
}

- (void)bcDidAcceptInput {
  // accept input
  if ([_delegate respondsToSelector:@selector(bcDidAcceptInput)])
    [(NSObject *)_delegate performSelectorOnMainThread:@selector(bcDidAcceptInput)
					    withObject:nil
					 waitUntilDone:YES];
}

// bc c-to-obj bridge
void bc_iphone_putchar(int ch) {
  objc_msgSend(pObject, @selector(bcDidPutCharacter:), ch);
}
 
void bc_input_mode_on() {
  objc_msgSend(pObject, @selector(flush));
  objc_msgSend(pObject, @selector(bcWillWaitForInput));
}

void bc_input_mode_off() {
  objc_msgSend(pObject, @selector(bcDidAcceptInput));
}

@end
