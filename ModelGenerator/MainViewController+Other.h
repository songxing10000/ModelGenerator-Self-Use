//
//  MainViewController+Other.h
//  ModelGenerator
//
//  Created by mac on 2017/8/25.
//  Copyright © 2017年 zhubch. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController (Other)
- (void)showAlertWithString:(NSString *)str;
- (void)removeSpaceStringOrNilStringFromMutableArray:(NSMutableArray *)arr;


- (NSAttributedString *)btnAttributedStringWithtitle:(NSString *)title;
- (void)makeRound:(NSView*)view;
- (NSString *)removeSpaceAndNewline:(NSString *)str;
/// 是否为空或者是空格
BOOL isEmpty(NSString *str);
@end
