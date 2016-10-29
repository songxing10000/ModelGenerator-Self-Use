//
//  MainViewController+Show.m
//  ModelGenerator
//
//  Created by dfpo on 16/10/29.
//  Copyright © 2016年 zhubch. All rights reserved.
//

#import "MainViewController+Show.h"

@implementation MainViewController (Show)

- (void)showAlertWithString:(NSString *)str {
    
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = str;
    [alert addButtonWithTitle:@"好的"];
    alert.alertStyle = NSWarningAlertStyle;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [alert runModal];
    }];
}
@end
