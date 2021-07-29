//
//  NSPlaceHolderTextView.m
//  ModelGenerator
//
//  Created by dfpo on 29/07/2021.
//  Copyright © 2021 zhubch. All rights reserved.
//

#import "NSPlaceHolderTextView.h"


@implementation NSPlaceHolderTextView
- (BOOL)becomeFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super becomeFirstResponder];
}
- (void)setM_placeHolderString:(NSString *)m_placeHolderString {
    _m_placeHolderString = [m_placeHolderString mutableCopy];
    [self setNeedsDisplay:YES];
}
- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if (self.string.length <= 0 && self.m_placeHolderString.length > 0){
        
        NSColor *txtColor = [NSColor grayColor];
        NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys:txtColor, NSForegroundColorAttributeName, nil];
        
        NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:self.m_placeHolderString attributes:txtDict];
        [attStr drawAtPoint:NSMakePoint(5,0)];
    }
         
}

- (BOOL)resignFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super resignFirstResponder];
}
@end
