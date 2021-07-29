//
//  MainViewController.h
//  ModelGenerator
//
//  Created by zhubch on 15/8/11.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSPlaceHolderTextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : NSViewController

@property (unsafe_unretained) IBOutlet NSPlaceHolderTextView *codeTextView;

@property (unsafe_unretained) IBOutlet NSPlaceHolderTextView *jsonTextView;
/// 生成按钮
@property (weak) IBOutlet NSButton *startBtn;
/// 复制按钮
@property (weak) IBOutlet NSButton *m_copyBtn;
@end
NS_ASSUME_NONNULL_END

