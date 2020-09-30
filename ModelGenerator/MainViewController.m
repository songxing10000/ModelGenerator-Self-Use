//
//  MainViewController.m
//  ModelGenerator
//
//  Created by zhubch on 15/8/11.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "MainViewController.h"

#import "MainViewController+Other.h"
typedef NSString *(^LineMapStringBlock)(NSArray<NSString *> *lineStrs);

@interface MainViewController ()<NSComboBoxDataSource,NSTextViewDelegate>

@property (weak) IBOutlet NSButton *emptyBtn;
@property (weak) IBOutlet NSPopUpButton *popUpBtn;


@end

@implementation MainViewController
{
    
    id objectToResolve;
    NSString *result;
}
#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [_jsonTextView becomeFirstResponder];
    
    
    _startBtn.attributedTitle = [self btnAttributedStringWithtitle:@"生成"];
    self.emptyBtn.attributedTitle = [self btnAttributedStringWithtitle:@"清空"];
    _m_copyBtn.attributedTitle = [self btnAttributedStringWithtitle:@"复制"];

    
    //    generater.language = ObjectiveC;
    
    [self makeRound:_startBtn];
    [self makeRound:_m_copyBtn];

    [self makeRound:self.emptyBtn];
}
#pragma mark - action

- (IBAction)popUpBtnAction:(NSPopUpButton *)sender {
    
    NSLog(@"sender.indexOfSelectedItem===%ld",(long)sender.indexOfSelectedItem);
    __unused NSInteger selectedIndex = sender.indexOfSelectedItem;
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
/// 复制事件
- (IBAction)clickCopyBtn:(NSButton *)sender {
    NSPasteboard *bd = [NSPasteboard generalPasteboard];
    [bd clearContents];
    [bd setString:self.codeTextView.string forType:NSPasteboardTypeString];
}
/// 生成事件
- (IBAction)generate:(id)sender {
    
    NSString *currentLanguage = [self.popUpBtn selectedItem].title;
    if (currentLanguage.length <=0 ) {
        [self showAlertWithString:@"请先选择一个转换格式"];
        return;
    }
    
    
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
    } else if ([currentLanguage isEqualToString:@"pythonHeader"]){
        
        [self pythonHeader];
    } else if ([currentLanguage isEqualToString:@"状态码-描述-状态码含义"]) {
        
        [self statusCode_statusCodeDes_statusCodeMeaning];
    } else if ([currentLanguage isEqualToString:@"状态码-描述"]) {
        
        [self statusCode_statusCodeDes];
    }
    
    else if ([currentLanguage isEqualToString:@"参数名称-参数说明-参数类型-备注"]){
        
        [self name_des_type_remark];
    } else if ([currentLanguage isEqualToString:@"参数名称-参数类型-是否必传-参数示例-参数说明"]){
        
        [self name_type_must_example_des];
    }
    else if ([currentLanguage isEqualToString:  @"showdoc.cc 参数名-必选-字段含义-类型"]){
        
        [self name_must_des_type];
    }
    else if ([currentLanguage isEqualToString:  @"showdoc.cc 参数名-必选-类型-字段含义"]){
        
        [self name_must_type_des];
    }
    else if ([currentLanguage isEqualToString:  @"showdoc.cc 参数名-必选-类型-字段含义   转为接口请求参数"]){
        
        [self name_must_type_desUploadApi];
    }
    else if ([currentLanguage isEqualToString:  @"showdoc.cc 参数名-类型-说明"]){
        
        [self name_type_des];
    }
    else if ([currentLanguage isEqualToString:@"参数名称-参数类型-默认值-是否为空-主键-索引-注释-备注"]){
        
        [self name_type_defaultValue_isEmpty_primaryKey_index_zhuShi_not];
    }
    
    else if ([currentLanguage isEqualToString:@"字段名-类型-示例值-备注"]){
        
        [self name_type_example_des];
    }
    else if ([currentLanguage isEqualToString:@"参数名称-参数类型-是否必填-参数说明"]){
        [self name_type_must_des];
    }
    else if ([currentLanguage isEqualToString:@"showdoc.cc 参数名-类型-字段含义-必选"]){
        [self name_type_des_must];
    }
    else if ([currentLanguage isEqualToString:@"XcodePrintToJSONString"]){
        
        [self XcodePrintToJSONString];
    }else if ([currentLanguage isEqualToString:@"OC代码取JSON字符串"]){
        
        [self OCParamDictToJSONString];
    } else if ([currentLanguage isEqualToString:@"小程序url转换"]) {
        [self minAppURLConversion];
    } else if ([currentLanguage isEqualToString:@"谷歌翻译转换"]) {
        [self googleTranslateConversion];
    } else if ([currentLanguage isEqualToString:@"字符串转换成数组"]) {
        [self convertStringToArray];
    } else if ([currentLanguage isEqualToString:@"JSON字符串转OC模型"]) {
        [self JSONStringToOCModel];
    }
    
    
}
/**
 字符串转字典
 */
- (NSDictionary *)dictFromJSONString:(NSString *)jsonStr {
    
    if (jsonStr == nil) {
        return nil;
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if(err) {
        NSLog(@"----%@---", err.userInfo[@"NSDebugDescription"]);
        return nil;
    }
    return dic;
}
/// JSON字符串转OC模型
- (void)JSONStringToOCModel {
    
    
    // json转字典
    NSString *str = [self removeSpaceAndNewline: [self.jsonTextView.string stringByReplacingOccurrencesOfString:@"null" withString:@"\"null\""]];
    str = [str stringByReplacingOccurrencesOfString:@";" withString:@","];
    str = [str stringByReplacingOccurrencesOfString:@",}" withString:@"}"];
    NSDictionary *dict = [self dictFromJSONString: str];
    if (!dict ||
        ![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSMutableString *outStr = [NSMutableString string];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[NSString class]]) {
            
            [outStr appendFormat:@"/// 如，%@\n",value];
            [outStr appendFormat:@"@property(nonatomic, copy) NSString *%@;\n",key];
        } else if ([value isKindOfClass:[NSNumber class]]){
            
            [outStr appendFormat:@"/// 如，%@\n",value];
            [outStr appendFormat:@"@property(nonatomic, strong) NSNumber *%@;\n",key];
        } else if ([value isKindOfClass:[NSArray class]]){
            
            [outStr appendFormat:@"/// 如，%@\n",value];
            [outStr appendFormat:@"@property(nonatomic, strong) NSArray *%@;\n",key];
        }
    }];
    
    
    [self operationCompletedWithString:outStr];
}
/// 操作完毕，写入textview
- (void)operationCompletedWithString:(NSString *)outStr {
    if (isEmpty(outStr)) {
        return;
    }
    self.codeTextView.editable = YES;
    [self.codeTextView insertText:@"" replacementRange:NSMakeRange(0, self.codeTextView.textStorage.string.length)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.codeTextView insertText:outStr replacementRange:NSMakeRange(0, 1)];
        self.codeTextView.editable = NO;
    });
}
/// 一排有多少个元素，多少个占位
- (NSMutableArray<NSArray<NSString *> *> *)getLineCodeStrsFromStr:(NSString *)inputStr rowNum:(NSUInteger)rowNum {
    NSArray<NSString *> *strings=  [inputStr componentsSeparatedByString:@"\n"];
    NSMutableArray<NSArray<NSString *> *> *lineCodeStrs = @[].mutableCopy;
    // 四个一组
    for (NSInteger i = 0; i < [strings count] ; i ++) {
        
        NSMutableArray *arr1 = [NSMutableArray array];
        NSInteger counts = 0;
        
        while (counts != rowNum && i < [strings count]  ) {
            counts++;
            
            [arr1 addObject:strings[i]];
            
            i ++;
            
            
        }
        if (arr1.count == rowNum) {
            
            [lineCodeStrs addObject:arr1.copy];
        }
        
        i --;
    }
    return lineCodeStrs;
}
#pragma mark - 状态码-描述
/// 状态码-描述
- (void)statusCode_statusCodeDes {
    
    [self xsColumn:2 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {
        NSString *statusCode = lineStrs[0];
        NSString *statusDes = lineStrs[1];
        NSString *codeString =
        [NSString stringWithFormat: @"@\"%@\" : @\"%@\",\n", statusCode, statusDes];
        return codeString;
    }];
    
}
/// 状态码-描述-状态码含义
- (void)statusCode_statusCodeDes_statusCodeMeaning {
    
    [self xsColumn:3 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {
        NSString *statusCode = lineStrs[0];
        NSString *statusDes = lineStrs[1];
        NSString *statusDetailDes = lineStrs[2];
        
        NSString *codeString =
        [NSString stringWithFormat: @"@\"%@\" : @\"%@%@\",\n", statusCode, statusDes,statusDetailDes];
        return codeString;
    }];
}
- (NSString *)objcClassStrFromStr:(NSString *)str {
    if ([str isEqualToString:@"int"] ||
        [str isEqualToString:@"Int"] ||
        [str isEqualToString:@"integer"] ||
        [str isEqualToString:@"Integer"]) {
        
        return  @"NSInteger";
    } else if ([str isEqualToString:@"string"] ||
               [str isEqualToString:@"String"] ||
               [str isEqualToString:@"str"] ||
               [str isEqualToString:@"Str"]) {
        
        return @"NSString *";
    } else if ([str isEqualToString:@"arry"]||
               [str isEqualToString:@"arr"] ||
               [str isEqualToString:@"Array"] ||
               [str isEqualToString:@"array"]) {
        
        return @"NSArray *";
    }
    return @"NSString *";
}
- (NSString *)modifierStrFromObjcClassStr:(NSString *)str {
    NSDictionary *dict = @{@"NSString *":@"copy",
                           @"NSArray *":@"strong",
                           @"NSNumber *":@"strong",
                           @"NSDictionary *":@"strong",
                           };
    
    return dict[str]?:@"assign";
}
#pragma mark - 参数名-类型-字段含义-必选
- (void)name_type_des_must {
    
    [self xsColumn:4 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {
        NSString *propertyName = lineStrs[0];
        NSString *classStr = lineStrs[1];
        NSString *propertyDes = lineStrs[2];
        if (!isEmpty(classStr) &&
            ![classStr isEqualToString:@"对象"]) {
            
            NSString *rightClassStr = [self objcClassStrFromStr:classStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            
            NSString *codeString =
            [NSString stringWithFormat:
             @"\n///  %@ \n@property (nonatomic, %@) %@ %@;\n",
             propertyDes, modifierStr,rightClassStr, propertyName];
            
            return codeString;
        }
        return @"";
    }];
}
#pragma mark - 参数名称-参数类型-是否必填-参数说明
- (void)name_type_must_des {
    
    [self xsColumn:4 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {
        NSString *propertyName = lineStrs[0];
        NSString *classStr = lineStrs[1];
        NSString *propertyDes = lineStrs[3];
        if (!isEmpty(classStr) &&
            ![classStr isEqualToString:@"对象"]) {
            
            NSString *rightClassStr = [self objcClassStrFromStr:classStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            
            NSString *codeString =
            [NSString stringWithFormat:
             @"\n///  %@ \n@property (nonatomic, %@) %@ %@;\n",
             propertyDes, modifierStr,rightClassStr, propertyName];
            
            return codeString;
        }
        return @"";
    }];
}
/// 字段名-类型-示例值-备注
- (void)name_type_example_des {
    
    
    [self xsColumn:4 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {

        NSString *propertyName = lineStrs[0];
        NSString *classStr = lineStrs[1];
        NSString *propertyDes1 = lineStrs[3];
        NSString *propertyDes2 = lineStrs[2];
        if (!isEmpty(classStr)&&
            ![classStr isEqualToString:@"对象"]) {
            NSString *rightClassStr = [self objcClassStrFromStr:classStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            NSString *codeString =
            [NSString stringWithFormat:
             @"\n///  %@ 例如-> %@\n@property (nonatomic, %@) %@ %@;\n",
             propertyDes1, propertyDes2, modifierStr, rightClassStr, propertyName];
            return codeString;
        }
        return @"";
    }];
    
}
#pragma mark 参数名称-参数类型-默认值-是否为空-主键-索引-注释-备注
/// 参数名称-参数类型-默认值-是否为空-主键-索引-注释-备注
- (void)name_type_defaultValue_isEmpty_primaryKey_index_zhuShi_not {
    
    [self xsColumn:8 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {

        
        /// 参数名称
        NSString *propertyName = lineStrs[0];
        /// 参数类型
        NSString *propertyClassTypeStr = lineStrs[1];
        /// 参数说明
        NSString *propertyDes = lineStrs[6];
        /// 参数说明
        NSString *propertyDes2 = lineStrs[7];
        if (!isEmpty(propertyClassTypeStr) &&
            ![propertyClassTypeStr isEqualToString:@"对象"]) {
            // integer Integer int Int String string arr
            NSString *rightClassStr = [self objcClassStrFromStr:propertyClassTypeStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            
            NSString *codeString =
            [NSString stringWithFormat:
             @"\n///  %@ %@ \n@property (nonatomic, %@) %@ %@;\n",
             propertyDes,propertyDes2,modifierStr,rightClassStr, propertyName];
            
            return codeString;
        }
        return @"";
    }];
   
}
/// showdoc.cc 参数名-类型-说明
- (void)name_type_des {
    
    
    [self xsColumn:3 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {

        
        /// 参数名称
        NSString *propertyName = lineStrs[0];
        /// 参数类型
        NSString *propertyClassTypeStr = lineStrs[1];
        /// 参数说明
        NSString *propertyDes = lineStrs[2];
        if (!isEmpty(propertyClassTypeStr) &&
            ![propertyClassTypeStr isEqualToString:@"对象"]) {
            // integer Integer int Int String string arr
            NSString *rightClassStr = [self objcClassStrFromStr:propertyClassTypeStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            
            
            NSString *codeString =
            [NSString stringWithFormat:
             @"\n///  %@ \n@property (nonatomic, %@) %@ %@;\n",
             propertyDes, modifierStr, rightClassStr, propertyName];
            
            return codeString;
            
            
            
        }
        return @"";
    }];
    
    
}
/// showdoc.cc 参数名-必选-类型-字段含义   转为接口请求参数
- (void)name_must_type_desUploadApi {
    NSString *inputString = self.jsonTextView.string;
    if (![inputString containsString:@"\n"]) {
        return;
    }
    NSMutableArray<NSArray<NSString *> *> *lineCodeStrs =
    [self getLineCodeStrsFromStr:inputString rowNum: 4];
    
    NSMutableString *outPutString = @"\nNSMutableDictionary *dict = [NSMutableDictionary dictionary];\n".mutableCopy;
    [lineCodeStrs enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull lineStrs, NSUInteger idx, BOOL * _Nonnull stop) {
        /// 参数名称
        NSString *pName = lineStrs[0];
        /// 参数必须性
        __unused BOOL canNull = ([lineStrs[1] isEqualToString:@"否"]);
        /// 参数类型
        NSString *pClass = lineStrs[2];
        /// 参数说明
        NSString *pDes = lineStrs[3];
        if (!isEmpty(pClass) &&
            ![pClass isEqualToString:@"对象"]) {
            // integer Integer int Int String string arr
            NSString *rightClassStr = [self objcClassStrFromStr:pClass];
            /// 修饰符 copy strong assign
            __unused NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            
            [outPutString appendString: [NSString stringWithFormat:@"\n///  %@", pDes]];
            [outPutString appendString: [NSString stringWithFormat:@"\ndict[@\"%@\"] = @\"\";", pName]];

        }
    }];
    [self operationCompletedWithString:outPutString];
}
/// showdoc.cc 参数名-必选-类型-字段含义
- (void)name_must_type_des {
    
    [self xsColumn:4 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {

        
        /// 参数名称
        NSString *propertyName = lineStrs[0];
        /// 参数类型
        NSString *propertyClassTypeStr = lineStrs[2];
        /// 参数说明
        NSString *propertyDes = lineStrs[3];
        if (!isEmpty(propertyClassTypeStr) &&
            ![propertyClassTypeStr isEqualToString:@"对象"]) {
            // integer Integer int Int String string arr
            NSString *rightClassStr = [self objcClassStrFromStr:propertyClassTypeStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            NSString *nullStr = @"";
            if ([lineStrs[1] isEqualToString:@"否"]) {
                nullStr = @", nullable";
            }
            
            
            NSString *codeString =
            [NSString stringWithFormat:
             @"\n///  %@ \n@property (nonatomic, %@%@) %@ %@;\n",
             propertyDes, modifierStr, nullStr, rightClassStr, propertyName];

            return codeString;
        }
        return @"";
    }];
    
}
/// showdoc.cc 参数名-必选-字段含义-类型
- (void)name_must_des_type {
    
    
    [self xsColumn:4 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {
        
        
        /// 参数名称
        NSString *propertyName = lineStrs[0];
        /// 参数类型
        NSString *propertyClassTypeStr = lineStrs[3];
        /// 参数说明
        NSString *propertyDes = lineStrs[2];
        if (!isEmpty(propertyClassTypeStr) &&
            ![propertyClassTypeStr isEqualToString:@"对象"]) {
            // integer Integer int Int String string arr
            NSString *rightClassStr = [self objcClassStrFromStr:propertyClassTypeStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
       
            
            NSString *nullStr = @"";
            if ([lineStrs[1] isEqualToString:@"否"]) {
                nullStr = @", nullable";
            }
            
            
            NSString *codeString =
            [NSString stringWithFormat:
             @"\n///  %@ \n@property (nonatomic, %@%@) %@ %@;\n",
             propertyDes, modifierStr, nullStr, rightClassStr, propertyName];
            return codeString;
        }
        return @"";
    }];
           
}
/// 参数名称-参数类型-是否必传-参数示例-参数说明
- (void)name_type_must_example_des {
    
    
    [self xsColumn:4 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {

        
        /// 参数名称
        NSString *propertyName = lineStrs[0];
        /// 参数类型
        NSString *propertyClassTypeStr = lineStrs[1];
        /// 参数说明
        NSString *propertyDes = lineStrs[4];
        if (!isEmpty(propertyClassTypeStr) &&
            ![propertyClassTypeStr isEqualToString:@"对象"]) {
            // integer Integer int Int String string arr
            NSString *rightClassStr = [self objcClassStrFromStr:propertyClassTypeStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            
            
            NSString *codeString =
            [NSString stringWithFormat:
             @"\n///  %@ \n@property (nonatomic, %@) %@ %@;\n",
             propertyDes,rightClassStr, modifierStr, propertyName];
            
            
            
            
            return codeString;
        }
        return @"";
    }];
    
    
    
    
}
/// 参数名称-参数说明-参数类型-备注
- (void)name_des_type_remark {
    
        [self xsColumn:4 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {

        
        NSString *propertyName = lineStrs[0];
        NSString *propertyDes1 = lineStrs[1];
        NSString *classStr = lineStrs[2];
        NSString *propertyDes2 = lineStrs[3];
        if (!isEmpty(classStr) &&
            ![classStr isEqualToString:@"对象"]) {
            
            // integer Integer int Int String string arr
            NSString *rightClassStr = [self objcClassStrFromStr:classStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            
            
            NSString *codeString =
            [NSString stringWithFormat:
             @"\n///  %@ : %@\n@property (nonatomic, %@) %@ %@;\n",
             propertyDes1, propertyDes2, modifierStr,rightClassStr, propertyName];
            
            return codeString;
            
            
            
        }
            return @"";
    }];
    
    
    
    
}
- (void)pythonHeader {
    NSMutableString *inputString =  self.jsonTextView.string.mutableCopy;
    
    if ([inputString containsString:@"	.	"]) {
        /*
         .	Host:www.jianshu.com
         .	If-None-Match:W/"01370c870657c5581f082ee63f9e537b"
         .	Proxy-Connection:keep-alive
         */
        // chrome 拷贝会有这个
        inputString = [inputString stringByReplacingOccurrencesOfString:@"	.	" withString:@""].mutableCopy;
        NSArray<NSString *> *keyAndValueStrings = [inputString componentsSeparatedByString:@"\n"];
        NSMutableString *muStr = @"".mutableCopy;
        [keyAndValueStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
            if (isEmpty(string)) {
                
            } else {
                
                NSArray<NSString *> *keyAndValue = [string componentsSeparatedByString:@":"];
                if (keyAndValue.count < 2) {
                    
                    NSLog(@"----%@---", keyAndValue);
                }else{
                    
                    NSString *key = keyAndValue[0];
                    NSString *value = keyAndValue[1];
                    
                    [muStr appendFormat:@"\n'%@' : '%@' ,", key, value];
                }
            }
            
        }];
        self.codeTextView.string = muStr;
    } else if ([inputString containsString:@"名称	值\n"]) {
        /*
         
         名称	值
         Referer	https://www.baidu.com/
         If-None-Match	"1ec5-502264e2ae4c0"
         Cache-Control	max-age=0
         If-Modified-Since	Wed, 03 Sep 2014 10:00:27 GMT
         User-Agent	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/603.3.8 (KHTML, like Gecko) Version/10.1.2 Safari/603.3.8
         */
        // safari 拷贝会有这个
        inputString = [inputString stringByReplacingOccurrencesOfString:@"名称	值\n" withString:@""].mutableCopy;
        NSArray<NSString *> *keyAndValueStrings = [inputString componentsSeparatedByString:@"\n"];
        NSMutableString *muStr = @"".mutableCopy;
        [keyAndValueStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
            if (isEmpty(string)) {
                
            } else {
                
                NSArray<NSString *> *keyAndValue = [string componentsSeparatedByString:@"	"];
                if (keyAndValue.count < 2) {
                    
                    NSLog(@"----%@---", keyAndValue);
                }else{
                    
                    NSString *key = keyAndValue[0];
                    NSString *value = keyAndValue[1];
                    
                    [muStr appendFormat:@"\n'%@' : '%@' ,", key, value];
                }
            }
            
        }];
        self.codeTextView.string = muStr;
    } else if ([inputString containsString:@" = "] && [inputString containsString:@";"]) {
        /*
         Xcode打印请求参数
         
         appmac = 000000;
         appversion = "3.5.0";
         authorization = "Basic MTg5MDAwMDAwMDE6Y2hlMDAx";
         channel = 2;
         deviceId = 000000;
         deviceName = "iPhone Simulator";
         height = "667.000000";
         imei = 000000;
         imsi = 000000;
         loginWay = 1;
         system = IOS;
         sysversion = "11.200000";
         width = "375.000000";
         
         */
        inputString = [inputString stringByReplacingOccurrencesOfString:@" = " withString:@":"].mutableCopy;
        inputString = [inputString stringByReplacingOccurrencesOfString:@";" withString:@""].mutableCopy;
        
        NSArray<NSString *> *keyAndValueStrings = [inputString componentsSeparatedByString:@"\n"];
        NSMutableString *muStr = @"".mutableCopy;
        [keyAndValueStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
            if (isEmpty(string)) {
                
            } else {
                string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSArray<NSString *> *keyAndValue = [string componentsSeparatedByString:@":"];
                if (keyAndValue.count < 2) {
                    
                    NSLog(@"----%@---", keyAndValue);
                }else{
                    
                    NSString *key = keyAndValue[0];
                    NSString *value = keyAndValue[1];
                    value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    value = [value stringByReplacingOccurrencesOfString:@"\'" withString:@""];
                    [muStr appendFormat:@"\n'%@' : '%@' ,", key, value];
                }
            }
            
        }];
        self.codeTextView.string = muStr;
    }
    
}

/**
 Xcode 打印出来的字典转换成JSON字符串，方便postman传参
 */
- (void)XcodePrintToJSONString {
    NSMutableString *inputString =  self.jsonTextView.string.mutableCopy;
    
    if (([inputString containsString:@" = "] && [inputString containsString:@";"]) ||
        ([inputString containsString:@" = "] && [inputString containsString:@","])) {
        /*
         Xcode打印请求参数
         
         appmac = 000000;
         appversion = "3.5.0";
         authorization = "Basic MTg5MDAwMDAwMDE6Y2hlMDAx";
         channel = 2;
         deviceId = 000000;
         deviceName = "iPhone Simulator";
         height = "667.000000";
         imei = 000000;
         imsi = 000000;
         loginWay = 1;
         system = IOS;
         sysversion = "11.200000";
         width = "375.000000";
         
         */
        inputString = [inputString stringByReplacingOccurrencesOfString:@" = " withString:@":"].mutableCopy;
        inputString = [inputString stringByReplacingOccurrencesOfString:@";" withString:@""].mutableCopy;
        
        NSArray<NSString *> *keyAndValueStrings = [inputString componentsSeparatedByString:@"\n"];
        NSMutableString *muStr = @"{".mutableCopy;
        [keyAndValueStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
            if (isEmpty(string)) {
                
            } else {
                string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSArray<NSString *> *keyAndValue = [string componentsSeparatedByString:@":"];
                if (keyAndValue.count < 2) {
                    
                    NSLog(@"----%@---", keyAndValue);
                }else{
                    
                    NSString *key = keyAndValue[0];
                    NSString *value = keyAndValue[1];
                    value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    value = [value stringByReplacingOccurrencesOfString:@"\'" withString:@""];
                    
                    [muStr appendFormat:@"\n\"%@\" : \"%@\" ,", key, value];
                    
                    
                }
            }
            
        }];
        // 去除,
        
        
        [muStr deleteCharactersInRange: NSMakeRange(muStr.length-1, 1)];
        // 换行加}
        self.codeTextView.string = [muStr stringByAppendingString:@"\n}"];;
    }
    
}

/**
 从OC代码里网络请求传递的参数字典转换成JSON字符串，方便postman传参
 */
- (void)OCParamDictToJSONString {
    NSMutableString *inputString =  self.jsonTextView.string.mutableCopy;
    
    
    /*
     Xcode打印请求参数
     
     params[@"newTelNum"] = self.tellNewNumber.text;
     params[@"checkCode"] = self.verificationTextField.text;
     params[@"templateType"] = @"SMSMOBILEMODIFY";
     params[@"validateKey"] = self.validateKey;
     
     */
    inputString = [inputString stringByReplacingOccurrencesOfString:@"params[@\"" withString:@"\""].mutableCopy;
    /*
     "newTelNum"] = self.tellNewNumber.text;
     "checkCode"] = self.verificationTextField.text;
     "templateType"] = @"SMSMOBILEMODIFY";
     "validateKey"] = self.validateKey;
     */
    
    inputString = [inputString stringByReplacingOccurrencesOfString:@"\"] = @\"" withString:@"\" : \""].mutableCopy;
    inputString = [inputString stringByReplacingOccurrencesOfString:@"\"] = " withString:@"\" : "].mutableCopy;
    /*
     "newTelNum":self.tellNewNumber.text;
     "checkCode":self.verificationTextField.text;
     "templateType":@"SMSMOBILEMODIFY";
     "validateKey":self.validateKey;
     */
    inputString = [inputString stringByReplacingOccurrencesOfString:@"\";" withString:@"\","].mutableCopy;
    inputString = [inputString stringByReplacingOccurrencesOfString:@";" withString:@","].mutableCopy;
    
    NSMutableString *muStr = @"{\n".mutableCopy;
    [muStr appendString:inputString];
    [muStr deleteCharactersInRange: NSMakeRange(muStr.length-1, 1)];
    // 换行加}
    self.codeTextView.string = [muStr stringByAppendingString:@"\n}"];;
    
    
}
/**
 小程序url转换
 url: utils.kBaseUrl + '/nw/entrance/apis/contract/serviceprotocol/json',
 
 
 
 稳盈管理页面信息
 
 mine_steadyManagementPageInfo: kBaseUrl + '/nw/entrance/apis/loan/querycurrentamount/json',
 */
- (void)minAppURLConversion {
    NSMutableString *inputString =  self.jsonTextView.string.mutableCopy;
    // 冒号分割后的数组
    /*
     <__NSArrayM 0x60000004a4d0>(
     url,
     utils.kBaseUrl + '/nw/entrance/apis/contract/serviceprotocol/json',
     
     )
     */
    NSArray<NSString *> *colonStirngs = [inputString componentsSeparatedByString:@":"];
    if (colonStirngs.count < 2) {
        // 尝试解析 var url = utils.kBaseUrl + '/nw/entrance/apis/xsb/profitdetail/json';
        if ([inputString containsString:@"var"] && [inputString containsString:@"="]) {
            colonStirngs = [inputString componentsSeparatedByString:@"="];
            if (colonStirngs.count < 2) {
                return;
            }
            
        } else {
            
            return;
        }
    }
    //  colonStirngs[1] 为 utils.kBaseUrl + '/nw/entrance/apis/contract/serviceprotocol/json',
    
    // 加号分割后的数组
    /*
     <__NSArrayM 0x60800004be50>(
     utils.kBaseUrl ,
     '/nw/entrance/apis/contract/serviceprotocol/json',
     
     )
     */
    NSArray<NSString *> *plusStrings = [colonStirngs[1] componentsSeparatedByString:@"+"];
    if (plusStrings.count < 2) {
        return;
    }
    // utils.kBaseUrl ,
    // 子地址 '/nw/entrance/apis/contract/serviceprotocol/json'
    NSString *subURLString = plusStrings[1];
    
    // kBaseUrl +  '/nw/entrance/apis/contract/serviceprotocol/json',
    NSString *allURLString = [NSString stringWithFormat:@"kBaseUrl + %@", subURLString];
    NSArray<NSString *> *subURLStringOtherNameStrings = [subURLString componentsSeparatedByString:@"/"];
    NSString *subURLStringOtherNameString = @"???";
    if (subURLStringOtherNameStrings.count >= 2) {
        subURLStringOtherNameString = subURLStringOtherNameStrings[subURLStringOtherNameStrings.count -2];
    }
    NSString *commentString = [NSString stringWithFormat:@"/**\n * %@\n */\nmine_%@: %@", @"中文注释",subURLStringOtherNameString,allURLString];
    // 以;结尾
    self.codeTextView.string = [commentString stringByReplacingOccurrencesOfString:@";" withString:@""];
    
    
}

/**
 谷歌翻译转换
 输入：
 Google Translate Conversion
 输出：
 m_googleTranslateConversion
 googleTranslateConversion
 */
- (void)googleTranslateConversion {
    
    NSString *inputString =  self.jsonTextView.string;
    
    /// 去除所有空格，首字母小写，加或不加  m_
    inputString = [self removeSpaceAndNewline:inputString];
    BOOL hasInput = inputString && inputString.length > 0;
    if (!hasInput) {
        return;
    }
    NSString *firstLetter = [inputString substringWithRange:NSMakeRange(0, 1)];
    
    inputString = [inputString stringByReplacingOccurrencesOfString:firstLetter withString:[firstLetter lowercaseString]];
    NSMutableString *outStr = [NSMutableString string];
    [outStr appendString:@"\n"];
    [outStr appendString:@"\n"];
    
    [outStr appendString:[@"m_" stringByAppendingString:inputString]];
    [outStr appendString:@"\n"];
    [outStr appendString:@"\n"];
    
    [outStr appendString:inputString];
    self.codeTextView.string = outStr;
    
    
}

/**
 字符串转换成数组
 输入：
 法定代表人/负责人、
 
 总经理、
 
 部门负责人、
 
 员工
 输出：
 @[@"法定代表人/负责人",@"总经理",@"部门负责人",@"员工"]
 */
- (void)convertStringToArray {
    
    NSString *inputString =  self.jsonTextView.string;
    
    /// 去除所有空格，首字母小写，加或不加  m_
    inputString = [self removeSpaceAndNewline:inputString];
    BOOL hasInput = inputString && inputString.length > 0;
    if (!hasInput) {
        return;
    }
    NSArray<NSString *> *strs = [inputString componentsSeparatedByString:@"、"];
    NSMutableString *muStr = [NSMutableString string];
    [muStr appendString:@"@["];
    [strs enumerateObjectsUsingBlock:^(NSString * _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
        [muStr appendFormat:@"@\"%@\", ",str];
    }];
    NSString *outStr = [muStr substringWithRange:NSMakeRange(0, muStr.length -2)];
    self.codeTextView.string = [outStr stringByAppendingString:@"]"];
    
    
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
    [self removeSpaceStringOrNilStringFromMutableArray:lineCodeStrings];
    
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
    [self operationCompletedWithString:rightCodeString];
    
    
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
    //    [self removeSpaceStringOrNilStringFromMutableArray:lineCodeStrings];
    NSInteger lieNum = 3;
    if ([lineCodeStrings[2] isEqualToString:@"是"] ||
        [lineCodeStrings[2] isEqualToString:@"否"] ||
        [lineCodeStrings[2] isEqualToString:@"非"] ||
        [lineCodeStrings[2] isEqualToString:@"不是"] ||
        [lineCodeStrings[1] isEqualToString:@"false"] ||
        [lineCodeStrings[1] isEqualToString:@"true"] ||
        [lineCodeStrings[2] isEqualToString:@"Integer"] ||
        [lineCodeStrings[2] isEqualToString:@"String"] ||
        [lineCodeStrings[2] isEqualToString:@"Int"] ||
        [lineCodeStrings[2] isEqualToString:@"对象"]
        ) {
        
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
            } else if ([lineArray[2] isEqualToString:@"Integer"] ||
                       [lineArray[2] isEqualToString:@"String"] ||
                       [lineArray[2] isEqualToString:@"Int"] ||
                       [lineArray[2] isEqualToString:@"对象"]) {
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
            } else if ([lineArray[2] isEqualToString:@"Integer"] ||
                       [lineArray[2] isEqualToString:@"String"] ||
                       [lineArray[2] isEqualToString:@"Int"] ||
                       [lineArray[2] isEqualToString:@"对象"]){
                
                descString = lineArray[1];
                NSString *str = [lineArray[3].mutableCopy stringByReplacingOccurrencesOfString:@"（varchar）" withString:@""];
                if (!isEmpty(str)) {
                    
                    descString =
                    [NSString stringWithFormat:@"%@ -> %@",lineArray[1],str];
                }
                
            }else {
                
                descString =
                [NSString stringWithFormat:@"%@，是否必填->%@",
                 [lineArray[3].mutableCopy stringByReplacingOccurrencesOfString:@"（varchar）" withString:@""],
                 lineArray[2]];
            }
            
        }
        NSString *objectStr = @"*";
        
        if ([className isEqualToString:@"string"] ||
            [className isEqualToString:@"String"]) {
            
            className = @"NSString";
        } else if ([className isEqualToString:@"int"] ||
                   [className isEqualToString:@"Int"] ||
                   [className isEqualToString:@"Integer"]) {
            
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
            
        } else if ([className isEqualToString:@"float"]) {
            className = @"float";
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
                 @"\n///  %@\n@property (nonatomic) %@ %@ %@;\n",
                 descString, className, objectStr, propertyName];
            } else {
                
                if (idx == 0) {
                    
                    codeString = [NSString stringWithFormat:@"@{\n\n\t@\"%@\": @1,\n", propertyName];
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
    [self operationCompletedWithString:rightCodeString];
    
    
}

#pragma mark - action
- (IBAction)selectedLanguage:(NSComboBox*)sender {
    
    NSInteger idx = sender.indexOfSelectedItem;
    BOOL showJsonPlaceHoler = idx <= 2;
    self.placeHolder.placeholderString =  showJsonPlaceHoler ? @"请输入Json文本" : @"请输入api文本";
}

#pragma mark NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray<NSValue *> *)affectedRanges replacementStrings:(nullable NSArray<NSString *> *)replacementStrings{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.placeHolder.hidden = textView.textStorage.string.length > 0;
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
#pragma mark - 方法抽取

/// 通用处理
/// @param column 一行里有多少列数据
/// @param lineMap 每一行怎么转换成代码
- (void)xsColumn:(NSInteger)column lineMap:(LineMapStringBlock)lineMap{
    NSString *inputString = self.jsonTextView.string;
    if (![inputString containsString:@"\n"]) {
        return;
    }
    NSAttributedString *atStr = self.jsonTextView.attributedString;
    if (atStr.length > 0) {
        /// 有些table块里好几个换行，按table块来重新组装inputString
        /// 先把每个table块里的放拼接成一个字符串，放数组里
        /// 然后用 \n 拼接成 inputString
        NSMutableArray<NSString *> *lineCodeStrs2 = @[].mutableCopy;
        NSMutableArray<NSTextBlock *> *tabMuArr = @[].mutableCopy;
        [atStr enumerateAttributesInRange:NSMakeRange(0, atStr.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            NSAttributedString *subAtStr = [atStr attributedSubstringFromRange:range];
            if ([subAtStr.string isEqualToString:@"\n"]) {
                return;
            }
            NSArray<NSTextBlock *> *textBlocks = [attrs[@"NSParagraphStyle"] textBlocks];
            NSAssert(textBlocks.count>0, @"没有blocks咋办");
            if(textBlocks.count > 0) {
                NSTextBlock *textBlock = textBlocks[0];
                /// 在同一个小table块里的textBlock是同一个对象
                NSUInteger idx = [tabMuArr indexOfObject:textBlock];
                if (idx != NSNotFound) {
                    NSString *oldStr = lineCodeStrs2[idx];
                    NSString *addStr = [oldStr stringByAppendingString:subAtStr.string];
                    if (addStr.length > 0) {
                        lineCodeStrs2[idx] = [addStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    }
                } else {
                    [tabMuArr addObject:textBlock];
                    [lineCodeStrs2 addObject:[self removeSpaceAndNewline:subAtStr.string]];
                }

            }
        }];
        [self removeSpaceStringOrNilStringFromMutableArray:lineCodeStrs2];
        inputString = [lineCodeStrs2 componentsJoinedByString:@"\n"];
    }
     NSMutableArray<NSArray<NSString *> *> *lineCodeStrs =
    [self getLineCodeStrsFromStr:inputString rowNum: column];
    
    NSMutableString *outPutString = @"".mutableCopy;
    [lineCodeStrs enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull lineArray, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (lineArray.count > 0 && lineMap) {
            NSString *lineStr = lineMap(lineArray);
            if (lineStr.length > 0) {
                [outPutString appendString: lineStr];
            }
        }
    }];
    [self operationCompletedWithString:outPutString];
}
@end
