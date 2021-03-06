//
//  XVimEvaluator.m
//  XVim
//
//  Created by Shuichiro Suzuki on 2/3/12.  
//  Copyright 2012 JugglerShu.Net. All rights reserved.  
//

#import "XVim.h"
#import "XVimOptions.h"
#import "XVimEvaluator.h"
#import "XVimMotionEvaluator.h"
#import "XVimKeyStroke.h"
#import "Logger.h"
#import "XVimWindow.h"
#import "XVimKeymapProvider.h"
#import "XVimNormalEvaluator.h"
#import "XVimVisualEvaluator.h"
#import "XVim.h"
#import "NSTextView+VimOperation.h"
#import "XVimSearch.h"
#import "XVimCommandLineEvaluator.h"
#import "NSString+VimHelper.h"

static XVimEvaluator *_invalidEvaluator = nil;
static XVimEvaluator *_noOperationEvaluator = nil;
static XVimEvaluator *_popEvaluator = nil;

@implementation XVimEvaluator

@synthesize yankRegister = _yankRegister;
@synthesize numericArg = _numericArg;

+ (void)initialize
{
    if (self == [XVimEvaluator class]) {
        _invalidEvaluator = [[XVimEvaluator alloc] init];
        _noOperationEvaluator = [[XVimEvaluator alloc] init];
        _popEvaluator = [[XVimEvaluator alloc] init];
    }
}

+ (XVimEvaluator*)invalidEvaluator{
    return _invalidEvaluator;
}

+ (XVimEvaluator*)noOperationEvaluator{
    return _noOperationEvaluator;
}

+ (XVimEvaluator *)popEvaluator{
    return _popEvaluator;
}

- (id)init {
    self = [super init];
	return self;
}

- (id)initWithWindow:(XVimWindow*)window{
    NSAssert( nil != window, @"window must not be nil");
    if(self = [super init]){
        self.window = window;
        self.parent = nil;
        self.argumentString = [[NSMutableString alloc] init];
        self.numericArg = 1;
        self.numericMode = NO;
        self.yankRegister = nil;
        self.onChildCompleteHandler = @selector(onChildComplete:);
    }
    return self;
}


- (NSTextView*)sourceView
{
    return self.window.sourceView;
}

- (XVimEvaluator*)eval:(XVimKeyStroke*)keyStroke{
    // This is default implementation of evaluator.
    // Only keyDown events are supposed to be passed here.	
    // Invokes each key event handler
    // <C-k> invokes "C_k:" selector
	
	SEL handler = keyStroke.selector;
    if ([self respondsToSelector:handler]) {
		TRACE_LOG(@"Calling SELECTOR %@", NSStringFromSelector(handler));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:handler];
#pragma clang diagnostic pop
	}
    else{
        TRACE_LOG(@"SELECTOR %@ not found", NSStringFromSelector(handler));
        return [self defaultNextEvaluator];
    }
    
}

- (XVimEvaluator*)onChildComplete:(XVimEvaluator*)childEvaluator{
    return nil;
}
   
- (void)becameHandler{
    self.sourceView.xvimDelegate = self;
}

- (void)cancelHandler{
    self.sourceView.xvimDelegate = nil;
}

- (void)didEndHandler{
    self.sourceView.xvimDelegate = nil;
}

- (XVimKeymap*)selectKeymapWithProvider:(id<XVimKeymapProvider>)keymapProvider {
	return [keymapProvider keymapForMode:XVIM_MODE_NORMAL];
}

- (XVimEvaluator*)defaultNextEvaluator{
    return [XVimEvaluator invalidEvaluator];
}

- (float)insertionPointHeightRatio{
    return 1.0;
}

- (float)insertionPointWidthRatio{
    return 1.0;
}

- (float)insertionPointAlphaRatio{
    return 0.5;
}

- (NSString*)modeString {
	return @"";
}

- (XVIM_MODE)mode{
    return XVIM_MODE_NORMAL;
}

- (BOOL)isRelatedTo:(XVimEvaluator*)other {
	return other == self;
}

- (void)resetCompletionHandler{
    self.onChildCompleteHandler = @selector(onChildComplete:);
}

- (XVimEvaluator*)D_d{
    // This is for debugging purpose.
    // Write any debugging process to confirme some behaviour.
    return nil;
}

- (XVimEvaluator*)ESC{
    return [XVimEvaluator invalidEvaluator];
}

// Normally argumentString, but can be overridden
- (NSString*)argumentDisplayString {
    if( nil == self.parent ){
        return _argumentString;
    }else{
        return [[self.parent argumentDisplayString] stringByAppendingString:_argumentString];
    }
}

// Returns the context yank register if any
- (NSString*)yankRegister {
    // Never use self.yankRegister here. It causes INFINITE LOOP
    if( nil != _yankRegister ){
        return _yankRegister;
    }
    if( nil == self.parent ){
        return _yankRegister;
    }else{
        return [self.parent yankRegister];
    }
}

- (void)setYankRegister:(NSString *)yankRegister
{
    _yankRegister = yankRegister;
}

- (void)resetNumericArg{
    _numericArg = 1;
    if( self.parent != nil ){
        [self.parent resetNumericArg];
    }
}

// Returns the context numeric arguments multiplied together
- (NSUInteger)numericArg {
    // FIXME: This may lead integer overflow.
    // Just cut it to INT_MAX is fine for here I think.
    if( nil == self.parent ){
        return _numericArg;
    }else{
        return [self.parent numericArg] * _numericArg;
    }
}

- (void)setNumericArg:(NSUInteger)numericArg
{
    _numericArg = numericArg;
}

- (void)textView:(NSTextView*)view didYank:(NSString*)yankedText withType:(TEXT_TYPE)type{
    [[[XVim instance] registerManager] yank:yankedText withType:type onRegister:self.yankRegister];
    return;
}

- (void)textView:(NSTextView*)view didDelete:(NSString*)deletedText withType:(TEXT_TYPE)type{
    [[[XVim instance] registerManager] delete:deletedText withType:type onRegister:self.yankRegister];
    return;
}

- (XVimCommandLineEvaluator*)searchEvaluatorForward:(BOOL)forward{
	return [[XVimCommandLineEvaluator alloc] initWithWindow:self.window
                                                 firstLetter:forward?@"/":@"?"
                                                     history:[[XVim instance] searchHistory]
                                                  completion:^ XVimEvaluator* (NSString *command, id* result)
             {
                 if( command.length == 0 ){
                     return nil;
                 }
                 XVim.instance.foundRangesHidden = NO;
                 NSTextView* view = [self.window sourceView];
                 view.needsUpdateFoundRanges = YES;
                 
                 BOOL forward = [command characterAtIndex:0] == '/';
                 if( command.length == 1 ){
                     // Repeat search
                     XVimMotion* m = [XVim.instance.searcher motionForRepeatSearch];
                     m.motion = forward ? MOTION_SEARCH_FORWARD : MOTION_SEARCH_BACKWARD;
                     m.count = self.numericArg;
                     *result = m;
                 }else{
                     XVim.instance.searcher.lastSearchString = [command substringFromIndex:1];
                     XVimMotion* m = [XVim.instance.searcher motionForSearch:[command substringFromIndex:1] forward:forward];
                     m.count = self.numericArg;
                     *result = m;
                 }
                 return nil;
             }
             onKeyPress:^void(NSString *command)
             {
                 if( command.length < 2 ){
                     return;
                 }
                 
                 BOOL forward = [command characterAtIndex:0] == '/';
                 XVimMotion* m = [XVim.instance.searcher motionForSearch:[command substringFromIndex:1] forward:forward];
                 if( [command characterAtIndex:0] == '/' ){
                     [self.sourceView xvim_highlightNextSearchCandidateForward:m.regex count:self.numericArg option:m.option];
                 }else{
                     [self.sourceView xvim_highlightNextSearchCandidateBackward:m.regex count:self.numericArg option:m.option];
                 }
             }];
}

@end


