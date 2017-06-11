//
//  MainViewController.m
//  ModelGenerator
//
//  Created by zhubch on 15/8/11.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "MainViewController.h"
#import "MainViewController+Show.h"

@interface MainViewController ()<NSComboBoxDataSource,NSTextViewDelegate>

@property (weak) IBOutlet NSButton *emptyBtn;
@property (weak) IBOutlet NSPopUpButton *popUpBtn;

@end

@implementation MainViewController
{

    id objectToResolve;
    NSString *result;
    NSArray *languageArray;
}
#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(700, 400);
    languageArray = @[@"doc to OC property", @"doc to OC IB property", @"doc to OC dict", @"doc to postman bulk edit"];
    
    [_jsonTextView becomeFirstResponder];
    

    _startBtn.attributedTitle = [self btnAttributedStringWithtitle:@"生成"];
    self.emptyBtn.attributedTitle = [self btnAttributedStringWithtitle:@"清空"];
    
    
//    generater.language = ObjectiveC;
    
    [self makeRound:_startBtn];
    [self makeRound:self.emptyBtn];
}
#pragma mark - action

- (IBAction)popUpBtnAction:(NSPopUpButton *)sender {
    
    NSLog(@"sender.indexOfSelectedItem===%ld",(long)sender.indexOfSelectedItem);
    NSInteger selectedIndex = sender.indexOfSelectedItem;
//    self.isPost = (selectedIndex == 0)?YES:NO;
}

- (IBAction)checkChangeFromBtn:(NSButton *)sender {
    NSLog(@"----%tu---", sender.state);
}


#pragma mark empty btn
- (IBAction)clickemptyBtn:(NSButton *)sender {
    self.jsonTextView.string = @"";

}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
#pragma mark start btn
- (IBAction)generate:(id)sender {

    if (self.popUpBtn.indexOfSelectedItem >= languageArray.count) {
        [self showAlertWithString:@"请先选择一个转换格式"];
        return;
    }
    
    NSString *currentLanguage = languageArray[self.popUpBtn.indexOfSelectedItem];
    if ([currentLanguage isEqualToString:@"doc to OC property"]) {
        [self sosoapiToOCProperty:YES needOCDict:NO];
    } else if ([currentLanguage isEqualToString:@"doc to OC dict"])  {
        [self sosoapiToOCProperty:YES needOCDict:YES];
    }
    else if ([currentLanguage isEqualToString:@"doc to postman bulk edit"]) {
        [self sosoapiToOCProperty:NO  needOCDict:NO];
    } else if ([currentLanguage isEqualToString:@"doc to OC IB property"]) {
        // 生成IB连线
        [self sosoapiToOCIBProperty];
    }
    
}

/// 如果是OCProperty 就生成oc property code ,otherwise postman bulk edit
- (void)sosoapiToOCIBProperty{
    
    
    if (self.jsonTextView.textStorage.string.length == 0) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"无码不欢";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    
    NSString *inputString = _jsonTextView.textStorage.string;
    NSMutableArray <NSString *>*lineCodeStrings =
    [inputString componentsSeparatedByString:@"\n"].mutableCopy;
    
    // 12=4*3
    [self dealWithArray:lineCodeStrings];
    
    NSMutableArray *arrs = @[].mutableCopy;
    
    
    for (NSInteger i = 0; i < [lineCodeStrings count] ; i ++) {
        
        NSMutableArray *arr1 = [NSMutableArray array];
        NSInteger counts = 0;
        
        while (counts != 3 && i < [lineCodeStrings count]  ) {
            counts++;
            [arr1 addObject:lineCodeStrings[i]];
            i ++;
            
            
        }
        [arrs addObject:arr1];
        
        i --;
    }
    
    
    NSMutableArray *outPutArray = @[].mutableCopy;
    [arrs enumerateObjectsUsingBlock:^(NSArray<NSString *>  *_Nonnull lineArray, NSUInteger idx, BOOL * _Nonnull stop) {
        
            // 有注释
            
        NSString *propertyName = lineArray.firstObject;
        NSString *className = lineArray[1];
        NSString *descString = @"未找到该字段的注释";
        descString = [lineArray[2].mutableCopy stringByReplacingOccurrencesOfString:@"（varchar）" withString:@""];

       
        NSString *objectStr = @"*";
        
        if ([className isEqualToString:@"string"]) {
            className = @"NSString";
        } else if ([className isEqualToString:@"int"]) {
            className = @"NSInteger";
        } else if ([className isEqualToString:@"array"]) {
            className = @"NSArray";
        }
        if ([className isEqualToString:@"NSInteger"]) {
            objectStr = @" ";
        } else if ([className isEqualToString:@"NSString"]) {
            objectStr = @"  *";
        } else if ([className isEqualToString:@"NSArray"]) {
            objectStr = @"   *";
        }            
        
        NSString *codeString = @"??";
        
        if (![className isEqualToString:@"NSArray"]) {
            // NSArray 不需要生成IB
            
            codeString =
            [NSString stringWithFormat:@"///  %@\n__weak IBOutlet UILabel *_%@Label;\n\n", descString, propertyName];
            
        
            [outPutArray addObject:codeString];
        }
        
    }];

    NSString *rightCodeString = [outPutArray componentsJoinedByString:@""];
    self.codeTextView.editable = YES;
    [self.codeTextView insertText:@"" replacementRange:NSMakeRange(0, self.codeTextView.textStorage.string.length)];
    

// 操作完毕，写入textview
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.codeTextView insertText:rightCodeString replacementRange:NSMakeRange(0, 1)];
        self.codeTextView.editable = NO;
    });

}
/// 如果是OCProperty 就生成oc property code ,otherwise postman bulk edit
- (void)sosoapiToOCProperty:(BOOL)isOCProperty needOCDict:(BOOL)isNeedDict{
    
    
    if (self.jsonTextView.textStorage.string.length == 0) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"无码不欢";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    
    NSString *inputString = _jsonTextView.textStorage.string;
    NSMutableArray <NSString *>*lineCodeStrings =
    [inputString componentsSeparatedByString:@"\n"].mutableCopy;
    
    // 12=4*3
    [self dealWithArray:lineCodeStrings];
    NSInteger lieNum = 3;
    if ([lineCodeStrings[2] isEqualToString:@"是"] ||
        [lineCodeStrings[2] isEqualToString:@"否"] ||
        [lineCodeStrings[2] isEqualToString:@"非"] ||
        [lineCodeStrings[2] isEqualToString:@"不是"] ||
        [lineCodeStrings[1] isEqualToString:@"false"] ||
        [lineCodeStrings[1] isEqualToString:@"true"]) {
        
        lieNum = 4;///< 四列、含有 参数为必填与非必填
    } else {
        // 三行
        lieNum = 3;///< 三列、不包含 参数为必填与非必填
    }
    
    NSMutableArray *arrs = @[].mutableCopy;
    
    
    for (NSInteger i = 0; i < [lineCodeStrings count] ; i ++) {
        
        NSMutableArray *arr1 = [NSMutableArray array];
        NSInteger counts = 0;
        
        while (counts != lieNum && i < [lineCodeStrings count]  ) {
            counts++;
            [arr1 addObject:lineCodeStrings[i]];
            i ++;
            
            
        }
        [arrs addObject:arr1];
        
        i --;
    }
    
    
    NSMutableArray *outPutArray = @[].mutableCopy;
    [arrs enumerateObjectsUsingBlock:^(NSArray<NSString *>  *_Nonnull lineArray, NSUInteger idx, BOOL * _Nonnull stop) {
        // 有注释
        
        NSString *propertyName = lineArray.firstObject;
        NSString *className = @"NSObject";
        if ([lineArray count] >= 3) {
            className = lineArray[1];
            if ([lineArray[1] isEqualToString:@"false"] ||
                [lineArray[1] isEqualToString:@"true"]) {
                className = lineArray[2];
            }
        }
        NSString *descString = @"未找到该字段的注释";
        
        if (lieNum == 3) {
            if ([lineArray count] >= 3) {
                
                descString = [lineArray[2].mutableCopy stringByReplacingOccurrencesOfString:@"（varchar）" withString:@""];
            }
        } else if (lieNum == 4) {
            if ([lineArray[1] isEqualToString:@"false"] ||
                [lineArray[1] isEqualToString:@"true"]) {
            
                descString =
                [NSString stringWithFormat:@"%@，是否必填->%@",
                 [lineArray[3].mutableCopy stringByReplacingOccurrencesOfString:@"（varchar）" withString:@""],
                 lineArray[1]];
            } else {
                
                descString =
                [NSString stringWithFormat:@"%@，是否必填->%@",
                 [lineArray[3].mutableCopy stringByReplacingOccurrencesOfString:@"（varchar）" withString:@""],
                 lineArray[2]];
            }
            
        }
        NSString *objectStr = @"*";
        
        if ([className isEqualToString:@"string"]) {
            
            className = @"NSString";
        } else if ([className isEqualToString:@"int"]) {
            
            className = @"NSInteger";
            objectStr = @" ";
        } else if ([className isEqualToString:@"array"]) {
            
            className = @"NSArray";
        } else if ([className isEqualToString:@"NSInteger"]) {
            
            objectStr = @" ";
        } else if ([className isEqualToString:@"NSString"]) {
            
            objectStr = @"  *";
        } else if ([className isEqualToString:@"NSArray"]) {
            
            objectStr = @"   *";
        } else if ([className isEqualToString:@"boolean"]) {
            className = @"BOOL";
            objectStr = @"   ";

        } else {
            
            NSLog(@"----特别情况出现->%@---", className);
        }
        
        NSString *codeString = @"??";
        if (!isOCProperty) {
            
            codeString = [NSString stringWithFormat:@"%@:1\n", propertyName];
        } else  {
            if (!isNeedDict) {
                
                codeString =
                [NSString stringWithFormat:
                 @"///  %@\n@property (nonatomic) %@ %@ %@;\n\n",
                 descString, className, objectStr, propertyName];
            } else {
                
                if (idx == 0) {
                    
                    codeString = [NSString stringWithFormat:@"@{\n\t@\"%@\": @1,\n", propertyName];
                } else if (idx == arrs.count -1) {
                    
                    codeString = [NSString stringWithFormat:@"\t@\"%@\": @1 \n  }", propertyName];
                } else {
                    
                    codeString = [NSString stringWithFormat:@"\t@\"%@\": @1,\n", propertyName];
                }
            }
        }
        if (codeString && codeString.length) {
            
            [outPutArray addObject:codeString];
        }
    }];
    
    NSString *rightCodeString = [outPutArray componentsJoinedByString:@""];
    self.codeTextView.editable = YES;
    [self.codeTextView insertText:@"" replacementRange:NSMakeRange(0, self.codeTextView.textStorage.string.length)];
    
    
    // 操作完毕，写入textview
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.codeTextView insertText:rightCodeString replacementRange:NSMakeRange(0, 1)];
        self.codeTextView.editable = NO;
    });
    
}
#pragma mark - selected a language
- (IBAction)selectedLanguage:(NSComboBox*)sender {
    
    NSInteger idx = sender.indexOfSelectedItem;
    if (idx < languageArray.count) {
    
        return;
    }
    
//    generater.language = idx;
    BOOL showJsonPlaceHoler = idx <= 2;
    self.placeHolder.placeholderString =  showJsonPlaceHoler ? @"请输入Json文本" : @"请输入api文本";
}

#pragma mark NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray<NSValue *> *)affectedRanges replacementStrings:(nullable NSArray<NSString *> *)replacementStrings{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _placeHolder.hidden = textView.textStorage.string.length > 0;
    });
    return YES;
}

#pragma mark ClassViewControllerDelegate

- (void)didResolvedWithClassName:(NSString *)name
{
//    if (generater.language == ObjectiveC && ![name hasSuffix:@"*"]) {
//        name = [name stringByAppendingString:@"*"];
//    }
//    result = name;
}

#pragma mark NSComboBoxDelegate & NSComboBoxDataSource

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    
    return languageArray.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    
    return languageArray[index];
}


#pragma mark - private
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

- (void)dealWithArray:(NSMutableArray *)arr {
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

@end
