//
//  XVimTest.m
//  XVim
//
//  Created by Suzuki Shuichiro on 8/18/12.
//
//

#import "XVimTester.h"
#import "XVimTestCase.h"
#import <objc/runtime.h>
#import "Logger.h"
#import "IDEKit.h"
#import "XVimKeyStroke.h"
#import "XVimUtil.h"


@implementation XVimTester

- (void)createTestCases{
    // Text Definitions
    static NSString* text0 = @"aAa bbb ccc\n";
    
    static NSString* text1 = @"aaa\n"   // 0  (index of each WORD)
                             @"bbb\n"   // 4
                             @"ccc";    // 8
    
    static NSString* text2 = @"a;a bbb ccc\n"  // 0  4  8
                             @"ddd e-e fff\n"  // 12 16 20
                             @"ggg hhh i_i\n"  // 24 28 32
                             @"    jjj kkk";   // 36 40 44
   
    static NSString* a_result = @"aAa bbXXXb ccc\n";
    static NSString* A_result = @"aAa bbb cccXXX\n";
   
    static NSString* cw_result1 = @"aAa baaa ccc\n";
    static NSString* cw_result2 = @"aAa bbb caaa\n";
    static NSString* cw_result3 = @"aaa\nccc";
    static NSString* Cw_result1 = @"aAa baaaa\n";
    
    static NSString* oO_text = @"int abc(){\n"  // 0 4
                               @"}\n";          // 11
    
    static NSString* oO_result = @"int abc(){\n" // This result may differ from editor setting. This is for 4 spaces for indent.
                                 @"    \n"      // 11
                                 @"}\n";
    
    static NSString* guw_result = @"aaa bbb ccc\n";
    static NSString* gUw_result = @"AAA bbb ccc\n";
    static NSString* guu_result = @"aaa bbb ccc\n";
    static NSString* gUU_result = @"AAA BBB CCC\n";
    
    static NSString* tilde_result = @"Aaa bbb ccc\n";
    static NSString* g_tilde_w_result = @"AaA bbb ccc\n";
    
    static NSString* text_object0 = @"aaa(aaa)aaa";
    static NSString* text_object1 = @"bbb\"bbb\"bbb";
    static NSString* text_object2 = @"ccc{ccc}ccc";
    static NSString* text_object3 = @"ddd[ddd]ddd";
    static NSString* text_object4 = @"eee'eee'eee";
    static NSString* text_object5 = @"fff<fff>fff";
    static NSString* text_object6 = @"ggg`ggg`ggg";
    static NSString* text_object7 = @"hhh hhh hhh";
    
    static NSString* text_object_i_result0 = @"aaa()aaa";
    static NSString* text_object_a_result0 = @"aaaaaa";
    static NSString* text_object_i_result1 = @"bbb\"\"bbb";
    static NSString* text_object_a_result1 = @"bbbbbb";
    static NSString* text_object_i_result2 = @"ccc{}ccc";
    static NSString* text_object_a_result2 = @"cccccc";
    static NSString* text_object_i_result3 = @"ddd[]ddd";
    static NSString* text_object_a_result3 = @"dddddd";
    static NSString* text_object_i_result4 = @"eee''eee";
    static NSString* text_object_a_result4 = @"eeeeee";
    static NSString* text_object_i_result5 = @"fff<>fff";
    static NSString* text_object_a_result5 = @"ffffff";
    static NSString* text_object_i_result6 = @"ggg``ggg";
    static NSString* text_object_a_result6 = @"gggggg";
    static NSString* text_object_i_result7 = @"hhh  hhh";
    static NSString* text_object_a_result7 = @"hhh hhh";
    
    
    // Test Cases
    /*
     You can use "\x1B" to ESC
                 "\r"   to Enter
    */
    self.testCases      = [NSArray arrayWithObjects:
                          // Motions
                          // b, B
                          XVimMakeTestCase(text2,  6, 0,  @"b", text2,  4, 0),
                          XVimMakeTestCase(text2, 14, 0, @"3b", text2,  4, 0),
                          XVimMakeTestCase(text2,  4, 0,  @"B", text2,  0, 0),
                          XVimMakeTestCase(text2, 27, 0, @"3B", text2, 16, 0),
                          
                          // e, E
                          XVimMakeTestCase(text2, 16, 0,  @"e", text2, 17, 0),
                          XVimMakeTestCase(text2, 17, 0, @"3e", text2, 26, 0),
                          XVimMakeTestCase(text2, 16, 0,  @"E", text2, 18, 0),
                          XVimMakeTestCase(text2, 16, 0, @"3E", text2, 26, 0),
                          
                          // f, F
                          XVimMakeTestCase(text2,  0, 0,  @"fc", text2,  8, 0),
                          XVimMakeTestCase(text2,  0, 0, @"2fc", text2,  9, 0),
                          XVimMakeTestCase(text2, 18, 0,  @"Fd", text2, 14, 0),
                          XVimMakeTestCase(text2, 18, 0, @"2Fd", text2, 13, 0),
                          XVimMakeTestCase(text2, 24, 0, @"4fi", text2, 24, 0), // error case
                          
                          // g, G
                          XVimMakeTestCase(text2, 44, 0,  @"gg", text2,  8, 0),
                          XVimMakeTestCase(text2, 44, 0, @"3gg", text2, 32, 0),
                          XVimMakeTestCase(text2,  8, 0, @"9gg", text2, 44, 0),
                          XVimMakeTestCase(text2,  4, 0,   @"G", text2, 40, 0),
                          XVimMakeTestCase(text2, 44, 0,  @"3G", text2, 32, 0),
                          XVimMakeTestCase(text2,  8, 0,  @"9G", text2, 44, 0),
                          
                          
                          // h,j,k,l, <space>
                          XVimMakeTestCase(text1, 0, 0,   @"l", text1, 1, 0),
                          XVimMakeTestCase(text1, 0, 0, @"10l", text1, 2, 0),
                          XVimMakeTestCase(text1, 0, 0,   @"j", text1, 4, 0),
                          XVimMakeTestCase(text1, 0, 0, @"10j", text1, 8, 0),
                          XVimMakeTestCase(text1, 4, 0,   @"k", text1, 0, 0),
                          XVimMakeTestCase(text1, 1, 0,   @"h", text1, 0, 0),
                          XVimMakeTestCase(text1, 0, 0,   @" ", text1, 1, 0),
                          XVimMakeTestCase(text1, 0, 0, @"10 ", text1, 2, 0),
                          
                          // t, T
                          XVimMakeTestCase(text2,  0, 0,  @"tc", text2,  7, 0),
                          XVimMakeTestCase(text2,  0, 0, @"2tc", text2,  8, 0),
                          XVimMakeTestCase(text2, 18, 0,  @"Td", text2, 15, 0),
                          XVimMakeTestCase(text2, 18, 0, @"2Td", text2, 14, 0),
                          XVimMakeTestCase(text2, 24, 0, @"4ti", text2, 24, 0), // error case
                          
                          // w, W
                          XVimMakeTestCase(text2, 0, 0,  @"w", text2,  1, 0),
                          XVimMakeTestCase(text2, 0, 0, @"4w", text2,  8, 0),
                          XVimMakeTestCase(text2, 0, 0,  @"W", text2,  4, 0),
                          XVimMakeTestCase(text2, 0, 0, @"4W", text2, 16, 0),
                          
                          // 0, $, ^
                          XVimMakeTestCase(text2, 10, 0,   @"0", text2,  0, 0),
                          XVimMakeTestCase(text2,  0, 0,   @"$", text2, 10, 0),
                          XVimMakeTestCase(text2, 44, 0,   @"^", text2, 40, 0),
                          XVimMakeTestCase(text2, 44, 0, @"10^", text2, 40, 0), // Number does not affect caret
                          XVimMakeTestCase(text2, 36, 0,   @"^", text2, 40, 0),
                          XVimMakeTestCase(text2, 36, 0,   @"_", text2, 40, 0),
                          XVimMakeTestCase(text2, 32, 0,  @"2_", text2, 40, 0),
                          
                          // +, -, <CR>
                          XVimMakeTestCase(text2, 28, 0,  @"+", text2, 40, 0),
                          XVimMakeTestCase(text2, 16, 0, @"2+", text2, 40, 0),
                          XVimMakeTestCase(text2, 40, 0,  @"-", text2, 24, 0),
                          XVimMakeTestCase(text2, 40, 0, @"2-", text2, 12, 0),
                          XVimMakeTestCase(text2, 28, 0, @"\r", text2, 40, 0),
                          XVimMakeTestCase(text2, 16, 0,@"2\r", text2, 40, 0),
                          
                          // H,M,L
                          //TODO: Implement test for H,M,L. These needs some special test check method since we have to calc the height of the view.
                        
                          // Arrows( left,right,up,down )
                          
                          // Home, End, DEL
                          
                          // Motion type enforcing(v,V, Ctrl-v)
                          
                          // Searches (/,?,n,N,*,#)
                          
                          // , ; (comma semicolon) for f F
                          XVimMakeTestCase(text2, 0, 0,  @"2fb;", text2, 6, 0),
                          XVimMakeTestCase(text2, 0, 0,  @"fb2;", text2, 6, 0),
                          XVimMakeTestCase(text2, 0, 0,  @"2fb,", text2, 4, 0),
                          XVimMakeTestCase(text2, 0, 0, @"3fb2,", text2, 4, 0),
                           
                          XVimMakeTestCase(text2, 8, 0, @"2Fb;", text2, 4, 0),
                          XVimMakeTestCase(text2, 8, 0, @"Fb2;", text2, 4, 0),
                          XVimMakeTestCase(text2, 8, 0, @"2Fb,", text2, 6, 0),
                          XVimMakeTestCase(text2, 8, 0, @"3Fb2,", text2, 6, 0),
                           
                          // , ; (comma semicolon) for t T
                           
                          // Marks
                          XVimMakeTestCase(text2, 5,  0, @"majj3l`a", text2, 5, 0),
                          XVimMakeTestCase(text2, 5,  0, @"majj3l'a", text2, 0, 0),
                          
                          // Registers
                          
                          // Edits
                          // a, A
                          XVimMakeTestCase(text0, 5,  0, @"aXXX\x1B", a_result, 8, 0), // aXXX<ESC>
                          XVimMakeTestCase(text0, 5,  0, @"AXXX\x1B", A_result, 13, 0), // AXXX<ESC>
                          
                          // c, C
                          XVimMakeTestCase(text0, 5,  0, @"cwaaa\x1B", cw_result1,  7, 0),
                          XVimMakeTestCase(text0, 9,  0, @"cwaaa\x1B", cw_result2, 11, 0),
                          XVimMakeTestCase(text1, 1,  0, @"2cwaa\x1B", cw_result3,  2, 0),
                          XVimMakeTestCase(text0, 5,  0, @"Caaaa\x1B", Cw_result1,  8, 0),
                         
                          // gu, gU
                          XVimMakeTestCase(text0, 0,  0, @"guw", guw_result, 0, 0),
                          XVimMakeTestCase(text0, 0,  0, @"gUw", gUw_result, 0, 0),
                          XVimMakeTestCase(text0, 4,  0, @"guu", guu_result, 0, 0),
                          XVimMakeTestCase(text0, 4,  0, @"gUU", gUU_result, 0, 0),
                           
                          // ~, g~
                          XVimMakeTestCase(text0, 0,  0,     @"~~",     tilde_result,   2, 0),
                          XVimMakeTestCase(text0, 0,  0, @"~~hh~~",            text0,   2, 0),
                          XVimMakeTestCase(text0, 0,  0,    @"g~w", g_tilde_w_result,   0, 0),
                           
                          // o, O
                          XVimMakeTestCase(oO_text,  4, 0, @"o\x1B", oO_result, 14, 0),
                          XVimMakeTestCase(oO_text, 11, 0, @"O\x1B", oO_result, 14, 0),
                           
                          // Text Objects(TODO: with Numeric Arg)
                           
                          // (), b
                          XVimMakeTestCase(text_object0, 5, 0, @"di(", text_object_i_result0 , 4, 0),
                          XVimMakeTestCase(text_object0, 5, 0, @"di)", text_object_i_result0 , 4, 0),
                          XVimMakeTestCase(text_object0, 5, 0, @"da(", text_object_a_result0 , 3, 0),
                          XVimMakeTestCase(text_object0, 5, 0, @"da)", text_object_a_result0 , 3, 0),
                          XVimMakeTestCase(text_object0, 5, 0, @"dib", text_object_i_result0 , 4, 0),
                          XVimMakeTestCase(text_object0, 5, 0, @"dab", text_object_a_result0 , 3, 0),
                           
                          // "
                          XVimMakeTestCase(text_object1, 5, 0, @"di\"", text_object_i_result1 , 4, 0),
                          XVimMakeTestCase(text_object1, 5, 0, @"da\"", text_object_a_result1 , 3, 0),
                           
                          // {}, B
                          XVimMakeTestCase(text_object2, 5, 0, @"di{", text_object_i_result2 , 4, 0),
                          XVimMakeTestCase(text_object2, 5, 0, @"di}", text_object_i_result2 , 4, 0),
                          XVimMakeTestCase(text_object2, 5, 0, @"da{", text_object_a_result2 , 3, 0),
                          XVimMakeTestCase(text_object2, 5, 0, @"da}", text_object_a_result2 , 3, 0),
                          XVimMakeTestCase(text_object2, 5, 0, @"diB", text_object_i_result2 , 4, 0),
                          XVimMakeTestCase(text_object2, 5, 0, @"daB", text_object_a_result2 , 3, 0),
                           
                          // []
                          XVimMakeTestCase(text_object3, 5, 0, @"di[", text_object_i_result3 , 4, 0),
                          XVimMakeTestCase(text_object3, 5, 0, @"di]", text_object_i_result3 , 4, 0),
                          XVimMakeTestCase(text_object3, 5, 0, @"da[", text_object_a_result3 , 3, 0),
                          XVimMakeTestCase(text_object3, 5, 0, @"da]", text_object_a_result3 , 3, 0),
                           
                          // '
                          XVimMakeTestCase(text_object4, 5, 0, @"di'", text_object_i_result4 , 4, 0),
                          XVimMakeTestCase(text_object4, 5, 0, @"da'", text_object_a_result4 , 3, 0),
                           
                          // <>
                          XVimMakeTestCase(text_object5, 5, 0, @"di<", text_object_i_result5 , 4, 0),
                          XVimMakeTestCase(text_object5, 5, 0, @"di>", text_object_i_result5 , 4, 0),
                          XVimMakeTestCase(text_object5, 5, 0, @"da<", text_object_a_result5 , 3, 0),
                          XVimMakeTestCase(text_object5, 5, 0, @"da>", text_object_a_result5 , 3, 0),
                           
                          // `
                          XVimMakeTestCase(text_object6, 5, 0, @"di`", text_object_i_result6 , 4, 0),
                          XVimMakeTestCase(text_object6, 5, 0, @"da`", text_object_a_result6 , 3, 0),
                           
                          // w
                          XVimMakeTestCase(text_object7, 5, 0, @"diw", text_object_i_result7 , 4, 0),
                          XVimMakeTestCase(text_object7, 5, 0, @"daw", text_object_a_result7 , 4, 0),
                           
                          // Scrolls
                         
                          // Recordings
                           
                          // Key remaping
                          
                          // Visual mode
                           
                          // End of Test Cases
                          nil
                          ];
}

- (void)runTest{
    // Create Test Cases
    [self createTestCases];
    NSArray* testArray = self.testCases;
    
    // Alert Dialog to confirm current text will be deleted.
    NSAlert* alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Make it sure that a source test view has a focus now.\r Running test deletes text in current source text view. Proceed?"];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    NSInteger b = [alert runModal];
    
    // Run test for all the cases
    if( b == NSAlertFirstButtonReturn ){
        // test each
        for( NSUInteger i = 0; i < testArray.count; i++ ){
            [(XVimTestCase*)[testArray objectAtIndex:i] run];
        }
    }
    
    // Setup Talbe view to show result
    NSTableView* tableView= [[[NSTableView alloc] init] autorelease];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
   
    // Create Columns
    NSTableColumn* column1 = [[NSTableColumn alloc] initWithIdentifier:@"Description" ];
    [column1.headerCell setStringValue:@"Description"];
    NSTableColumn* column2 = [[NSTableColumn alloc] initWithIdentifier:@"Pass/Fail" ];
    [column2.headerCell setStringValue:@"Pass/Fail"];
    NSTableColumn* column3 = [[NSTableColumn alloc] initWithIdentifier:@"Message" ];
    [column3.headerCell setStringValue:@"Message"];
    [column3 setWidth:500.0];
    
    [tableView addTableColumn:column1];
    [tableView addTableColumn:column2];
    [tableView addTableColumn:column3];
    [tableView setAllowsMultipleSelection:YES];
    [tableView reloadData];
    
    // Setup the table view into scroll view
    NSScrollView* scroll = [[[NSScrollView alloc] initWithFrame:NSMakeRect(0,0,600,300)] autorelease];
    [scroll setDocumentView:tableView];
    [scroll setHasVerticalScroller:YES];
    [scroll setHasHorizontalScroller:YES];
    
    // Show it as a modal
    alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Result"];
    [alert setAccessoryView:scroll];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
    return (NSInteger)[self.testCases count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    if( [aTableColumn.identifier isEqualToString:@"Description"] ){
        return [(XVimTestCase*)[self.testCases objectAtIndex:(NSUInteger)rowIndex] description];
    }else if( [aTableColumn.identifier isEqualToString:@"Pass/Fail"] ){
        return ((XVimTestCase*)[self.testCases objectAtIndex:(NSUInteger)rowIndex]).success ? @"Pass" : @"Fail";
    }else if( [aTableColumn.identifier isEqualToString:@"Message"] ){
        return ((XVimTestCase*)[self.testCases objectAtIndex:(NSUInteger)rowIndex]).message;
    }
    return nil;
}

- (float)heightForString:(NSString*)myString withFont:(NSFont*)myFont withWidth:(float)myWidth{
    NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithString:myString] autorelease];
    NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(myWidth, FLT_MAX)] autorelease];
    NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init] autorelease];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:myFont
                        range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    (void) [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager
            usedRectForTextContainer:textContainer].size.height;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    NSFont* font;
    NSTableColumn* column = [tableView tableColumnWithIdentifier:@"Message"];
    if( nil != column ){
        NSCell* cell = (NSCell*)[column dataCell];
        font = [NSFont fontWithName:@"Menlo" size:13];
        [cell setFont:font]; // FIXME: This should not be done here.
        float width = column.width;
        NSString* msg = ((XVimTestCase*)[self.testCases objectAtIndex:(NSUInteger)row]).message;
        if( nil == msg || [msg isEqualToString:@""] ){
            msg = @" ";
        }
        float ret = [self heightForString:msg withFont:font withWidth:width];
        return ret + 5;
    }
    return 13.0;
}

@end
