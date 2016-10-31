//
//  MainViewController.m
//  ModelGenerator
//
//  Created by zhubch on 15/8/11.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "MainViewController.h"
#import "ModelGenerator.h"
#import "ClassViewController.h"
#import "MBProgressHUD.h"
#import "SXNetManager.h"
#import "MainViewController+Show.h"

@interface MainViewController ()<ClassViewControllerDelegate,NSComboBoxDataSource,NSTextViewDelegate,MBProgressHUDDelegate>

/// api to oc property use
@property (nonatomic) NSString *rightCodeString;

@property (weak) IBOutlet NSButton *emptyBtn;
@property (nonatomic)     MBProgressHUD *HUD;
@property (nonatomic)     NSMutableArray <NSDictionary<NSString*,NSString*>*>*outArr;

@property (weak) IBOutlet NSButton *needNetControl;
@end

@implementation MainViewController
{
    ModelGenerator *generater;
    id objectToResolve;
    NSString *result;
    NSArray *languageArray;
}
#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(700, 400);
    _outArr = @[].mutableCopy;
    languageArray = @[@"Objective-C",@"Swift",@"Java", @"Api to OC property", @"Sosoapi to OC property", @"Sosoapi to OC dict", @"Sosoapi to postman bulk edit"];
    generater = [ModelGenerator sharedGenerator];
    
    [_jsonTextView becomeFirstResponder];
    

    _comboBox.placeholderAttributedString = [self btnAttributedStringWithtitle:@"Language"];
    _classNameField.placeholderAttributedString = [self btnAttributedStringWithtitle:@"ClassName"];
    _startBtn.attributedTitle = [self btnAttributedStringWithtitle:@"Start"];
    self.emptyBtn.attributedTitle = [self btnAttributedStringWithtitle:@"empty"];
    self.needNetControl.attributedTitle = [self btnAttributedStringWithtitle:@"net"];
    _comboBox.stringValue = @"Objective-C";
    generater.language = ObjectiveC;
    [self makeRound:self.needNetControl];
    [self makeRound:_comboBox];
    [self makeRound:_classNameField];
    [self makeRound:_startBtn];
    [self makeRound:self.emptyBtn];
}
- (void)dfds {
    
    self.HUD = [[MBProgressHUD alloc] initWithWindow:self.view.window];
    
    [self.codeTextView addSubview:self.HUD];
    
    self.HUD.delegate = self;
    self.HUD.labelText = @"Loading";
    self.HUD.detailsLabelText = @"updating data";
    self.HUD.square = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.HUD show:YES];
    });
    
}

- (void)loadDataFromServerDealWithCode:(NSString *)code {
    [self dfds];
[[SXNetManager manager] getWithAPI:@"dbdoc.php" params:NULL HUDString:@"加载中..." success:^(NSString  *_Nullable string) {
    NSArray <NSString *>*arr1 = [string componentsSeparatedByString:@"\n"];
    NSMutableArray <NSDictionary<NSString*,NSString*>*>*outArr = @[].mutableCopy;
    
    [arr1 enumerateObjectsUsingBlock:^(NSString * _Nonnull linStr, NSUInteger idx, BOOL * _Nonnull stop) {
        linStr = [linStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([linStr isEqualToString:@"<tr class=\"odd\">"] ||
            [linStr isEqualToString:@"<tr class=\"even\">"] ||
            [linStr isEqualToString:@"<th>备注</th></tr>        <tr class=\"odd\">"]) {
            
            NSString *propertyName = arr1[idx + 1];
            propertyName = [propertyName stringByReplacingOccurrencesOfString:@"<td>" withString:@""];
            propertyName = [propertyName stringByReplacingOccurrencesOfString:@"</td>" withString:@""];
            propertyName = [propertyName stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            NSString *desStr = arr1[idx + 7];
            desStr = [desStr stringByReplacingOccurrencesOfString:@"<td>" withString:@""];
            desStr = [desStr stringByReplacingOccurrencesOfString:@"</td>" withString:@""];
            desStr = [desStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            [outArr addObject:@{propertyName: desStr}];
        } else {
            
        }
    }];
    self.outArr = outArr;
    NSArray <NSString *>*codes = [code componentsSeparatedByString:@"\n\n"];
    NSMutableArray <NSString *>*temArr   = @[].mutableCopy;
    
    [codes enumerateObjectsUsingBlock:^( NSString * _Nonnull codeLine, NSUInteger idx, BOOL * _Nonnull stop) {
    
            if ([codeLine hasPrefix:@"@property"]) {
                /*
                 @property (nonatomic,assign) NSInteger is_receive_much,

                 */
                
                NSString *pro = [[codeLine componentsSeparatedByString:@" "].lastObject stringByReplacingOccurrencesOfString:@";" withString:@""];
                for (NSDictionary *dict in self.outArr) {
                    if ([dict.allKeys.firstObject isEqualToString: pro]) {
                        
                       NSString *c = [NSString stringWithFormat:@"///  %@\n%@", dict.allValues.firstObject, codeLine].mutableCopy;
                        [temArr addObject:c];
                    }
                }
                
            }
        
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.HUD hide:YES];

        [temArr insertObject:codes.firstObject atIndex:0];
        [temArr insertObject:codes.lastObject atIndex:temArr.count];
        [self.codeTextView insertText:[temArr componentsJoinedByString:@"\n\n"]  replacementRange:NSMakeRange(0, 1)];
        self.codeTextView.editable = NO;
    });
} failure:^(NSString * _Nullable errorString) {
    
    [self showAlertWithString:errorString];
}];
}
#pragma mark - action

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

    if (self.comboBox.indexOfSelectedItem >= languageArray.count) {
        [self showAlertWithString:@"请先选择一个转换格式"];
        return;
    }
    
    NSString *currentLanguage = languageArray[self.comboBox.indexOfSelectedItem];
    if ([currentLanguage isEqualToString:@"Objective-C"]) {
        [self jsonToOCProperty];
    } else if ([currentLanguage isEqualToString:@"Swift"]) {
        [self jsonToOCProperty];

    } else if ([currentLanguage isEqualToString:@"Java-C"]) {
        [self jsonToOCProperty];

    } else if ([currentLanguage isEqualToString:@"Api to OC property"]) {
        [self apiToOCProperty];
    } else if ([currentLanguage isEqualToString:@"Sosoapi to OC property"]) {
        [self sosoapiToOCProperty:YES needOCDict:NO];
    } else if ([currentLanguage isEqualToString:@"Sosoapi to OC dict"])  {
        [self sosoapiToOCProperty:YES needOCDict:YES];
    }
    else if ([currentLanguage isEqualToString:@"Sosoapi to postman bulk edit"]) {
        [self sosoapiToOCProperty:NO  needOCDict:NO];
    }
    
}
#pragma mark jsonToOCProperty
- (void)jsonToOCProperty {
    if (self.jsonTextView.textStorage.string.length == 0) {
        [self showAlertWithString:@"请先输入要转换的Json文本"];
        return;
    }
    if (_classNameField.stringValue.length == 0) {
        [self showAlertWithString:@"请输入要生成的类名"];
        return;
    }
    if (generater.language == Unknow) {
        
        [self showAlertWithString:@"请选择语言"];

        return;
    }
    generater.className = _classNameField.stringValue;
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[_jsonTextView.textStorage.string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        
        [self showAlertWithString:@"无效的Json数据"];
        return;
    }
    self.codeTextView.editable = YES;
    [self.codeTextView insertText:@"" replacementRange:NSMakeRange(0, self.codeTextView.textStorage.string.length)];
    
    dispatch_async(dispatch_queue_create("generate", DISPATCH_QUEUE_CONCURRENT), ^{
        NSString *code = [generater generateModelFromDictionary:dic withBlock:^NSString *(id unresolvedObject) {
            
            objectToResolve = unresolvedObject;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"showModal" sender:self];
            });
            result = nil;
            
            while (result == nil) {
                sleep(0.1);
            }
            return result;
        }];
        if (self.needNetControl.state == 1) {
            // 需要加入网络来的注释
            [self loadDataFromServerDealWithCode:code];
            
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.codeTextView insertText:code replacementRange:NSMakeRange(0, 1)];
                self.codeTextView.editable = NO;
            });
        }
        
    });

}
#pragma mark apiToOCProperty
- (void)apiToOCProperty {
    
    if (self.jsonTextView.textStorage.string.length == 0) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"无码不欢";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    
    NSString *inputString = _jsonTextView.textStorage.string;
    NSArray *lineCodeStrings =
    [inputString componentsSeparatedByString:@"\n"];
    
    NSMutableArray <NSString *> *temArr = @[].mutableCopy;
    
    [lineCodeStrings enumerateObjectsUsingBlock:^(NSString  *_Nonnull lineCodeString, NSUInteger idx, BOOL * _Nonnull stop) {
        // lineCodeString ->  title           string      标题,
        NSMutableArray <NSString *>*arr = [lineCodeString.mutableCopy componentsSeparatedByString:@" "].mutableCopy;
        [self dealWithArray:arr];
        if (arr.count == 3) {
            NSString *propertyName = arr.firstObject;
            NSString *className = arr[1];
            NSString *descString = arr[2];
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
            NSString *codeString = [NSString stringWithFormat:@"///  %@\n@property (nonatomic) %@%@%@;\n\n", descString, className, objectStr, propertyName];
            [temArr addObject:codeString];
            
            NSLog(@"----%@---", codeString);
        }
        
        
    }];
    
    self.rightCodeString = [temArr componentsJoinedByString:@""];
    self.codeTextView.editable = YES;
    [self.codeTextView insertText:@"" replacementRange:NSMakeRange(0, self.codeTextView.textStorage.string.length)];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.codeTextView insertText:self.rightCodeString replacementRange:NSMakeRange(0, 1)];
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
    
    
    [self dealWithArray:lineCodeStrings];
    
    
    NSMutableArray *arrs = @[].mutableCopy;
    if (lineCodeStrings.count % 3 == 0) {
        // 有注释
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
    } else if (lineCodeStrings.count % 2 == 0) {
        // 没有注释
        for (NSInteger i = 0; i < [lineCodeStrings count] ; i ++) {
            
            NSMutableArray *arr1 = [NSMutableArray array];
            NSInteger counts = 0;
            
            while (counts != 2 && i < [lineCodeStrings count]  ) {
                counts++;
                [arr1 addObject:lineCodeStrings[i]];
                i ++;
                
                
            }
            [arrs addObject:arr1];
            
            i --;
        }
    }
    
    NSMutableArray *outPutArray = @[].mutableCopy;
    [arrs enumerateObjectsUsingBlock:^(NSArray<NSString *>  *_Nonnull lineArray, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (lineArray.count == 3) {
            // 有注释
            
            NSString *propertyName = lineArray.firstObject;
            NSString *descString = [lineArray[1].mutableCopy stringByReplacingOccurrencesOfString:@"（varchar）" withString:@""];
            NSString *className = lineArray[2];
            NSString *objectStr = @"*";
            
            if ([className isEqualToString:@"string"]) {
                className = @"NSString";
            } else if ([className isEqualToString:@"integer"]) {
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
            if (!isOCProperty) {
                
                    
                    codeString = [NSString stringWithFormat:@"%@:1\n", propertyName];
                

                
            } else  {
                if (isNeedDict) {
                    
                    /*
                     @{
                     @"":@"",
                     @"":@"",
                     @"":@"",
                     
                     @"":@""}
                     
                     */
                    if (idx == 0) {
                        
                        codeString = [NSString stringWithFormat:@"@{\n\t@\"%@\": @1,\n", propertyName];

                    } else if (idx == arrs.count -1) {
                        
                        codeString = [NSString stringWithFormat:@"\t@\"%@\": @1 \n  }", propertyName];

                    } else {
                        
                        codeString = [NSString stringWithFormat:@"\t@\"%@\": @1,\n", propertyName];
                    }
                    
                    
                } else {
                    
                    codeString = [NSString stringWithFormat:@"///  %@\n@property (nonatomic) %@%@%@;\n\n", descString, className, objectStr, propertyName];
                }
            }
            [outPutArray addObject:codeString];
        } else  if (lineArray.count == 2) {
            // 没有注释
            
            NSString *propertyName = lineArray.firstObject;
            NSString *className = lineArray[1];
            NSString *objectStr = @"*";
            
            if ([className isEqualToString:@"string"]) {
                className = @"NSString";
            } else if ([className isEqualToString:@"integer"]) {
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
            if (!isOCProperty) {
                
                
                codeString = [NSString stringWithFormat:@"%@:1\n", propertyName];
                
                
                
            } else  {
                if (isNeedDict) {
                    
                    /*
                     @{
                     @"":@"",
                     @"":@"",
                     @"":@"",
                     
                     @"":@""}
                     
                     */
                    if (idx == 0) {
                        
                        codeString = [NSString stringWithFormat:@"@{\n\t@\"%@\": @1,\n", propertyName];
                        
                    } else if (idx == arrs.count -1) {
                        
                        codeString = [NSString stringWithFormat:@"\t@\"%@\": @1 \n  }", propertyName];
                        
                    } else {
                        
                        codeString = [NSString stringWithFormat:@"\t@\"%@\": @1,\n", propertyName];
                    }
                    
                    
                } else {
                    
                    codeString = [NSString stringWithFormat:@"\n@property (nonatomic) %@%@%@;\n\n",  className, objectStr, propertyName];
                }
            }
            [outPutArray addObject:codeString];
        }

        
        
    }];

    self.rightCodeString = [outPutArray componentsJoinedByString:@""];
    self.codeTextView.editable = YES;
    [self.codeTextView insertText:@"" replacementRange:NSMakeRange(0, self.codeTextView.textStorage.string.length)];
    
//    if (self.needNetControl.state == 1) {
//        [self loadDataFromServerDealWithCode:self.rightCodeString];
//    } else {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.codeTextView insertText:self.rightCodeString replacementRange:NSMakeRange(0, 1)];
            self.codeTextView.editable = NO;
        });
//    }

}
#pragma mark - selected a language
- (IBAction)selectedLanguage:(NSComboBox*)sender {
    NSInteger idx = sender.indexOfSelectedItem;
    if (idx < languageArray.count) {
        generater.language = idx;
        
        BOOL showJsonPlaceHoler = idx <= 2;
        self.placeHolder.placeholderString =  showJsonPlaceHoler ? @"请输入Json文本" : @"请输入api文本";
        self.classNameField.hidden = !showJsonPlaceHoler;
        
        
        self.needNetControl.hidden = !(idx == 0 || idx == 4);
        
    }
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showModal"]) {
        ClassViewController *vc = segue.destinationController;
        vc.objectToResolve = objectToResolve;
        vc.delegate = self;
    }
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
    if (generater.language == ObjectiveC && ![name hasSuffix:@"*"]) {
        name = [name stringByAppendingString:@"*"];
    }
    result = name;
//    NSLog(@"%@",result);
}

#pragma mark NSComboBoxDelegate & NSComboBoxDataSource

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return languageArray.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return languageArray[index];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {

    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

#pragma mark - private
- (NSAttributedString *)btnAttributedStringWithtitle:(NSString *)title  {
    return [[NSAttributedString alloc]initWithString:title attributes:@{NSFontAttributeName: [NSFont fontWithName:@"Times New Roman" size:16],NSForegroundColorAttributeName:[NSColor whiteColor]}];
}
- (void)makeRound:(NSView*)view{
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 10;
    view.layer.borderWidth = 5;
    view.layer.borderColor = [NSColor whiteColor].CGColor;
}

- (void)dealWithArray:(NSMutableArray *)arr {
    [arr enumerateObjectsUsingBlock:^(NSString  *_Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([str isEqualToString:@" "] || [str isEqualToString:@"formData"]) {
            [arr removeObject:str];
        }
        BOOL hasValue = str && str.length;
        if (!hasValue) {
            [arr removeObject:str];
        }
        
    }];
}

@end
