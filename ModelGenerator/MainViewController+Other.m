//
//  MainViewController+Other.m
//  ModelGenerator
//
//  Created by mac on 2017/8/25.
//  Copyright © 2017年 zhubch. All rights reserved.
//

#import "MainViewController+Other.h"

@implementation MainViewController (Other)

- (void)showAlertWithString:(NSString *)str {
    
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = str;
    [alert addButtonWithTitle:@"好的"];
    alert.alertStyle = NSWarningAlertStyle;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [alert runModal];
    }];
}

- (void)removeSpaceStringOrNilStringFromMutableArray:(NSMutableArray *)arr {
    [arr enumerateObjectsUsingBlock:^(NSString  *_Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([str isEqualToString:@" "]) {
            [arr removeObject:str];
        }
        BOOL hasValue = str && str.length;
        if (!hasValue) {
            [arr removeObject:str];
        }
        
    }];
}


- (NSAttributedString *)btnAttributedStringWithtitle:(NSString *)title  {
    
    NSDictionary *dict = @{NSForegroundColorAttributeName:[NSColor whiteColor],
                           NSFontAttributeName: [NSFont fontWithName:@"Times New Roman" size:16]};
    return [[NSAttributedString alloc] initWithString:title
                                           attributes:dict];
}
- (void)makeRound:(NSView*)view{
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 10;
    view.layer.borderWidth = 5;
    view.layer.borderColor = [NSColor whiteColor].CGColor;
}

- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    

    temp = [temp stringByReplacingOccurrencesOfString:@"\t" withString:@""];
temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    return temp;
}
/// 是否为空或者是空格
BOOL isEmpty(NSString *str) {
    if (!str ||
        ![str isKindOfClass:[NSString class]] ||
        str.length <= 0 ||
        [str isEqualToString:@""]) {
        return YES;
    }
    NSString * newSelf = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!newSelf ||
        ![newSelf isKindOfClass:[NSString class]] ||
        newSelf.length <= 0 ||
        [newSelf isEqualToString:@""]) {
        return YES;
    }
    if([str isEqualToString:@"<null>"]
       || [str isEqualToString:@"(null)"]
       || [str isEqualToString:@"null"]
       || [newSelf isEqualToString:@"<null>"]
       || [newSelf isEqualToString:@"(null)"]
       || [newSelf isEqualToString:@"null"]){
        
        return YES;
        
    }else{
        // <object returned empty description> 会来这里
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        return [trimedString isEqualToString: @""];
    }
    
    return NO;
}
@end
