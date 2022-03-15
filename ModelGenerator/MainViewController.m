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
    
    self.jsonTextView.m_placeHolderString =   @"请输入api文本";
    self.codeTextView.m_placeHolderString =   @"请输入api文本";
    
}
#pragma mark - action

- (IBAction)popUpBtnAction:(NSPopUpButton *)sender {
    
    NSLog(@"sender.indexOfSelectedItem===%ld",(long)sender.indexOfSelectedItem);
    __unused NSInteger selectedIndex = sender.indexOfSelectedItem;
    //    self.isPost = (selectedIndex == 0)?YES:NO;
    self.jsonTextView.m_placeHolderString =    @"请输入api文本";
    
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
- (void)getDictFromURLStr {
    /*
     输入，如，https://www.91hilife.com/appmanage/upgrade/update?patchVersion=6.0.8&app=166&cType=1&appVersion=6.0.8&version=6.6.5&cVersion=6.6.5
     得到
     
     */
    NSMutableString *inputString =  self.jsonTextView.string.mutableCopy;
    if ([inputString containsString:@"?"]) {
        inputString = [NSMutableString stringWithString: [inputString componentsSeparatedByString:@"?"][1]];
    }
    // patchVersion=6.0.8&app=166&cType=1&appVersion=6.0.8&version=6.6.5&cVersion=6.6.5
    NSArray<NSString *> *keyAndvalues = [inputString componentsSeparatedByString:@"&"];
    NSMutableString *muStr = [NSMutableString string];
    [muStr appendString:@"NSMutableDictionary *dict = [NSMutableDictionary dictionary];\n"];
    [keyAndvalues enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj containsString:@"="]) {
            NSArray<NSString *> *keyValus = [obj componentsSeparatedByString:@"="];
            [muStr appendString: [NSString stringWithFormat:@"dict[@\"%@\"] = @\"%@\";\n", keyValus[0], keyValus[1]]];
        }
    }];
    // 换行加}
    self.codeTextView.string = muStr;
    
    
}
/// 生成事件
- (IBAction)generate:(id)sender {
    
    NSString *currentLanguage = [self.popUpBtn selectedItem].title;
    if (currentLanguage.length <=0 ) {
        [self showAlertWithString:@"请先选择一个转换格式"];
        return;
    }
    
    if ([currentLanguage isEqualToString:@"apifox"]){
        [self apifox];
    }
    else if ([currentLanguage isEqualToString:@"urlStr中的参数转字典"]) {
        [self getDictFromURLStr];
    }
    else if ([currentLanguage isEqualToString:@"doc to OC property"]) {
        [self sosoapiToOCProperty:YES needOCDict:NO];
    }
    else if ([currentLanguage isEqualToString:@"doc to OC dict"])  {
        [self sosoapiToOCProperty:YES needOCDict:YES];
    }
    else if ([currentLanguage isEqualToString:@"kancloud字段注释"])  {
        [self kancloudFieldAnnotation];
    }
    else if ([currentLanguage isEqualToString:@"字段名:示例值, // 描述说明"])  {
        [self fieldName_sampleValue_description];
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
    }
    else if ([currentLanguage isEqualToString:@"字段-含义-类型"]){
        
        [self name_des_type];
    }
    else if ([currentLanguage isEqualToString:@"字段-含义-是否必传-类型"]){
        
        [self name_des_must_type];
    }
    
    
    else if ([currentLanguage isEqualToString:@"参数名称-参数类型-是否必传-参数示例-参数说明"]){
        
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
    }
    else if ([currentLanguage isEqualToString:@"谷歌翻译转换"]) {
        [self googleTranslateConversion];
    } else if ([currentLanguage isEqualToString:@"字符串转换成数组"]) {
        [self convertStringToArray];
    } else if([currentLanguage isEqualToString:@"java后台entity转iOS模型"]) {
        NSString *inputString =  self.jsonTextView.string;
        // 按换行符切割
        NSArray<NSString *> *strs = [inputString componentsSeparatedByString:@"\n"];
        
        NSMutableArray<NSString *> *muStrs = [NSMutableArray array];
        [strs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 不要有@Column的这一行
            if (![obj containsString:@"@Column"] ||
                ![obj containsString:@"NotNull"]) {
                NSString *startEmptyStr = @"    ";
                NSString *desStr = obj;
                if ([obj hasPrefix:startEmptyStr]) {
                    // 去除首空格
                    desStr = [obj stringByReplacingCharactersInRange:[obj rangeOfString:startEmptyStr] withString:@""];
                }
                [muStrs addObject: desStr];
            }
        }];
        NSMutableArray<NSString *> *muStrs2 = [NSMutableArray array];
        
        [muStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *proStr = obj;
            if ([obj containsString:@"//"]) {
                // 这一行有注释
                NSArray<NSString *> *lineStrs = [obj componentsSeparatedByString:@"//"];
                [muStrs2 addObject:[NSString stringWithFormat:@"%@%@", @"/// ", lineStrs[1]]];
                proStr = lineStrs[0] ;
            }
            
            if ([proStr containsString:@"String"]) {
                
                [muStrs2 addObject: [NSString stringWithFormat:@"%@%@", @"@property(nonatomic, copy) NSString * ", [proStr componentsSeparatedByString:@" String "][1]]];
            }
            else if ([proStr containsString:@"Integer"]) {
                [muStrs2 addObject: [NSString stringWithFormat:@"%@%@", @"@property(nonatomic) NSInteger ", [proStr componentsSeparatedByString:@" Integer "][1]]];
            }
            else if ([proStr containsString:@"int"]) {
                [muStrs2 addObject: [NSString stringWithFormat:@"%@%@", @"@property(nonatomic) NSInteger ", [proStr componentsSeparatedByString:@" int "][1]]];
            }
            else if ([proStr containsString:@"java.util.Date"]) {
                [muStrs2 addObject: [NSString stringWithFormat:@"%@%@", @"@property (nonatomic) long ", [proStr componentsSeparatedByString:@" java.util.Date "][1]]];
            }
            else if ([proStr containsString:@"Date"]) {
                [muStrs2 addObject: [NSString stringWithFormat:@"%@%@", @"@property (nonatomic) long ", [proStr componentsSeparatedByString:@" Date "][1]]];
            }
            else if ([proStr containsString:@"boolean"]) {
                [muStrs2 addObject: [NSString stringWithFormat:@"%@%@", @"@property (nonatomic) BOOL ", [proStr componentsSeparatedByString:@" boolean "][1]]];
            }
            else if ([proStr containsString:@"BigDecimal"]) {
                [muStrs2 addObject: [NSString stringWithFormat:@"%@%@", @"@property (nonatomic) NSNumber * ", [proStr componentsSeparatedByString:@" BigDecimal "][1]]];
            }
            else if ([proStr containsString:@"Long"]) {
                [muStrs2 addObject: [NSString stringWithFormat:@"%@%@", @"@property (nonatomic) Long ", [proStr componentsSeparatedByString:@" Long "][1]]];
            }
            else if ([proStr containsString:@"List"]) {
                if ([proStr containsString:@">"]) {
                    // private List<Exercises> exercises
                    [muStrs2 addObject: [NSString stringWithFormat:@"%@%@", @"@property (nonatomic) NSArray * ", [proStr componentsSeparatedByString:@" >  "][1]]];
                } else {
                    // private List exercises
                    [muStrs2 addObject: [NSString stringWithFormat:@"%@%@", @"@property (nonatomic) NSArray * ", [proStr componentsSeparatedByString:@" List "][1]]];
                }
                
            }
            else {
                // 可能是自定义类如， private GlobalTags globalTag ;// 二级标签
                NSLog(@"%@ %@", NSStringFromSelector(_cmd), obj);
                
            }
            
               

        }];
        
        
        
        self.codeTextView.string = [muStrs2 componentsJoinedByString:@"\n"];
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
- (IBAction)didSelectedMenu:(NSPopUpButton *)sender {
    // 切换转换方式后，占位刷新
    if ([sender.title isEqualToString:@"urlStr中的参数转字典"]) {
        self.jsonTextView.m_placeHolderString = @"https://com/xtedu/api/studytask/getStudyTaskList?workId=671317&year=2021";
        self.codeTextView.m_placeHolderString = @"NSMutableDictionary *dict = [NSMutableDictionary dictionary];\ndict[@\"workId\"] = @\"671317\";\ndict[@\"year\"] = @\"2021\";\n";
    } else if([sender.title isEqualToString:@"java后台entity转iOS模型"]) {
        self.jsonTextView.m_placeHolderString = @"@Column\nprivate String roomName;//直播间名称\n@Column\nprivate Integer status;//状态(0未使用、1审核中、2已使用、3已过期)\n@Column\nprivate java.util.Date createTime;//获得时间";
        self.codeTextView.m_placeHolderString = @"///直播间名称\n@property(nonatomic, copy) NSString *roomName;\n///状态(0未使用、1审核中、2已使用、3已过期)\n@property(nonatomic) NSInteger status;\n///获得时间\n@property (nonatomic , assign) long createTime;";
    }
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
               [str isEqualToString:@"array"] ||
               [str isEqualToString:@"list"] ||
               [str isEqualToString:@"List"] ||
               [str isEqualToString:@"lis"]) {
        
        return @"NSArray *";
    }
    else if ([str isEqualToString:@"Boolean"]) {
        return @"BOOL";
    }
    else if ([str isEqualToString:@"BigDecimal"]) {
        return @"CGFloat";
    }
    else if ([str isEqualToString:@"Long"]) {
        return @"long";
    }
    //
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
- (void)name_des_must_type {
    [self xsColumn:4 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {
        
        
        /// 参数名称
        NSString *propertyName = lineStrs[0];
        /// 参数说明
        NSString *propertyDes = lineStrs[1];
        /// 参数类型
        NSString *propertyClassTypeStr = lineStrs[3];
        
        if (!isEmpty(propertyClassTypeStr) &&
            ![propertyClassTypeStr isEqualToString:@"对象"]) {
            // integer Integer int Int String string arr
            NSString *rightClassStr = [self objcClassStrFromStr:propertyClassTypeStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            NSString *nullStr = @"";
            if ([lineStrs[2] isEqualToString:@"否"]) {
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
#pragma mark - 参数名称-参数类型-是否必填-参数说明

- (void)name_type_must_des {
    
    [self xsColumn:4 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {
        NSString *propertyName = lineStrs[0];
        NSString *classStr = lineStrs[1];
        NSString *propertyDes = lineStrs[3];
        BOOL isCanNull = [lineStrs[2] isEqualToString:@"否"];
        
        if (!isEmpty(classStr) &&
            ![classStr isEqualToString:@"对象"]) {
            
            NSString *rightClassStr = [self objcClassStrFromStr:classStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            NSString *canNullStr = isCanNull?@", nullable":@"";
            
            NSString *codeString =
            [NSString stringWithFormat:
             @"\n///  %@ \n@property (nonatomic, %@%@) %@ %@;\n",
             propertyDes, modifierStr, canNullStr, rightClassStr, propertyName];
            //
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
/// 字段-含义-类型
- (void)name_des_type {
    
    [self xsColumn:3 lineMap:^NSString *(NSArray<NSString *> *lineStrs) {
        
        
        NSString *propertyName = lineStrs[0];
        NSString *propertyDes1 = lineStrs[1];
        NSString *classStr = lineStrs[2];
        if (!isEmpty(classStr) &&
            ![classStr isEqualToString:@"对象"]) {
            
            // integer Integer int Int String string arr
            NSString *rightClassStr = [self objcClassStrFromStr:classStr];
            /// 修饰符 copy strong assign
            NSString *modifierStr = [self modifierStrFromObjcClassStr:rightClassStr];
            
            
            
            NSString *codeString =
            [NSString stringWithFormat:
             @"\n///  %@ \n@property (nonatomic, %@) %@ %@;\n",
             propertyDes1, modifierStr,rightClassStr, propertyName];
            
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
// 字段名:示例值, // 描述说明
- (void)fieldName_sampleValue_description {
    /*
     "message": "", //更新文案
     "latestVersion": "", //最新app版本
     "updateStrategy": 1, //更新策略 0不更新 1推荐更新 2强制更新
     "noticeContent": 1, // 更新文案
     "noticeStartTime": 1, // 更新弹框开始时间
     "noticeEndTime": 1 // 更新弹框结束时间
     */
    NSString *inputString =  self.jsonTextView.string;
    NSArray<NSString *> *strs = [inputString componentsSeparatedByString:@"---"];
    NSString *proStr = strs[0];
    NSArray<NSString *> *rows =  [proStr componentsSeparatedByString:@"\n"];
    NSMutableDictionary<NSString *, NSArray<NSString *> *> *muDict = [NSMutableDictionary dictionary];
    [rows enumerateObjectsUsingBlock:^(NSString * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([line containsString:@":"] && [line containsString:@"//"]) {
            // line   "latestVersion": "", //最新app版本,
            NSArray<NSString *> *sepLines = [line componentsSeparatedByString:@":"];
            NSString *propertyName = [self removeSpaceAndNewline: sepLines[0]];
            NSString *sampleValue;
            NSString *desStr;
            NSString *typeStr;
            NSString *lineOtherStr = sepLines[1];
            
            NSArray<NSString *> *sepLines2 = [lineOtherStr componentsSeparatedByString: @"//"];
            sampleValue = [self removeSpaceAndNewline: sepLines2[0]];
            if ([sampleValue hasSuffix:@","]) {
                sampleValue = [sampleValue stringByReplacingOccurrencesOfString:@"," withString:@""];
            }
            if ([sampleValue isEqualToString:@"\"\""]) {
                typeStr = @"NSString *";
                NSLog(@"%@ %@", NSStringFromSelector(_cmd), typeStr);
            }
            else if ([sampleValue isEqualToString:@"0"] ||
                     [sampleValue isEqualToString:@"1"] ||
                     [sampleValue isEqualToString:@"[0,1]"] ||
                     [sampleValue isEqualToString:@"[01]"] ||
                     [sampleValue integerValue] > 0) {
                typeStr = @"NSInteger";
                NSLog(@"%@ %@", NSStringFromSelector(_cmd), typeStr);
            } else {
                
                NSLog(@"%@ %@", NSStringFromSelector(_cmd), sampleValue);
            }
            desStr = sepLines2[1];
            
            
            if ([propertyName hasPrefix:@"\""]) {
                propertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            if ([propertyName hasSuffix:@"\""]) {
                propertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(propertyName.length-1, 1) withString:@""];
            }
            muDict[propertyName] = @[desStr, typeStr];
        }
        
    }];
    NSMutableArray *muArr =  [NSMutableArray array];
    [muDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.count > 1) {
            if ([obj[1] isEqualToString:@"NSInteger"]) {
                [muArr addObject:[NSString stringWithFormat:@"/// %@\n@property (nonatomic , assign) NSInteger %@;", obj[0], key]];
                
            } else {
                [muArr addObject:[NSString stringWithFormat:@"/// %@\n@property (nonatomic , copy) NSString *%@;", obj[0], key]];
            }
        }
        else if (obj.count > 0) {
            [muArr addObject:[NSString stringWithFormat:@"/// %@\n@property (nonatomic , copy) NSString *%@;", obj[0], key]];
        }
    }];
    self.codeTextView.string = [muArr componentsJoinedByString:@"\n"];
    
    
}
- (void)kancloudFieldAnnotation {
    
    NSString *inputString =  self.jsonTextView.string;
    NSArray<NSString *> *strs = [inputString componentsSeparatedByString:@"---"];
    NSString *proStr = strs[0];
    if (strs.count < 2) {
        NSLog(@"%@ %@", NSStringFromSelector(_cmd), @"未找到分隔符 --- ");
        return;
    }
    NSString *desStr = strs[1];
    if (![strs[0] hasPrefix:@"@"]) {
        proStr = strs[1];
        desStr = strs[0];
    }
    /**
     @property (nonatomic , assign) NSInteger              is_jump;
     @property (nonatomic , assign) NSInteger              id;
     @property (nonatomic , copy) NSString              * img;
     @property (nonatomic , copy) NSString              * area;
     @property (nonatomic , copy) NSString              * url;
     @property (nonatomic , assign) NSInteger              add_time;
     
     
     "id":bannerID,
                 "img":路径地址,
                 "url":跳转路径,
                 "is_jump":是否跳转,
                 "area":banner位置,
     */
    NSMutableDictionary *muDict = [NSMutableDictionary dictionary];
    NSArray<NSString *> *desStrs = [desStr componentsSeparatedByString:@","];
    [desStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString *> *lineStrs = [[self removeSpaceAndNewline:line] componentsSeparatedByString:@":"];
        if (lineStrs.count > 1) {
            NSString *key = [self removeSpaceAndNewline: lineStrs[0]];
            if ([key hasPrefix:@"\""]) {
                key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            if ([key hasSuffix:@"\""]) {
                key = [key stringByReplacingCharactersInRange:NSMakeRange(key.length-1, 1) withString:@""];
            }
            NSString *value = [self removeSpaceAndNewline: lineStrs[1]];
            if ([value hasPrefix:@"\""]) {
                value = [value stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            if ([value hasSuffix:@"\""]) {
                // -[__NSCFString replaceCharactersInRange:withString:]: Range or index out of bounds
                if (key.length - 1 < value.length) {
                    
                    value = [value stringByReplacingCharactersInRange:NSMakeRange(key.length-1, 1) withString:@""];
                }
            }
            muDict[key] = value;
        }
    }];
    NSMutableArray<NSString *> *muArr = [NSMutableArray array];
    NSMutableArray<NSString *> *proNames = [NSMutableArray array];
    
    NSArray<NSString *> *proStrs = [proStr componentsSeparatedByString:@"\n"];
    for (NSString *line in proStrs) {
        NSArray<NSString *> *lineStrs = [line componentsSeparatedByString:@"              "];
        if (lineStrs.count > 1) {
            NSString *proName  = [lineStrs[1] stringByReplacingOccurrencesOfString:@";" withString:@""];
            proName = [proName stringByReplacingOccurrencesOfString:@"* " withString:@""];
            [proNames addObject:proName];
            NSString *proDes = muDict[proName];
            if (proDes.length > 0) {
                [muArr addObject:[NSString stringWithFormat:@"/// %@\n%@", proDes, line]];
            }
        }
    };
    // 注释上有字段[muDict allKeys]，但是接口没有返回此字段proNames
    [muDict enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull value, BOOL * _Nonnull stop) {
        if (![proNames containsObject: key]) {
            [muArr addObject:[NSString stringWithFormat:@"/// %@\n@property (nonatomic , copy) NSString *%@;", value, key]];
        }
    }];
    self.codeTextView.string = [muArr componentsJoinedByString:@"\n"];
    
    
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
#pragma mark - apifox
- (BOOL)hasChinese:(NSString *)str {
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}
- (void)apifox {
    NSMutableArray<NSString *> *muStrs = [NSMutableArray array];
    NSArray<NSString *> *ojs = [[self.jsonTextView string] componentsSeparatedByString:@"\n"];
    [ojs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.length > 0) {
            [muStrs addObject:obj];
        }
    }];
    NSMutableString *outStr = [NSMutableString string];
    [muStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([type isEqualToString:@"string"]) {
            NSString *des = muStrs[idx+1];
            if ([self hasChinese:des]) {
                // 是中文就说明这个字段有备注
                NSString *name = muStrs[idx-1];
                if (![outStr containsString:name]) {
                    [outStr appendFormat:@"\n/// %@\n", des];
                    [outStr appendFormat:@"@property(nonatomic, copy) NSString *%@;\n", name];
                    
                }
            }
        } else if ([type isEqualToString:@"integer"]) {
            NSString *des = muStrs[idx+1];
            if ([self hasChinese:des]) {
                // 是中文就说明这个字段有备注
                NSString *name = muStrs[idx-1];
                if (![outStr containsString:name]) {
                    [outStr appendFormat:@"\n/// %@\n", des];
                    [outStr appendFormat:@"@property(nonatomic, assign) NSInteger *%@;\n", name];
                }
                
            }
        } else if ([type isEqualToString:@"null"]) {
            // user_labels null 店主标签
            NSString *des = muStrs[idx+1];
            if ([self hasChinese:des]) {
                // 是中文就说明这个字段有备注
                NSString *name = muStrs[idx-1];
                if (![outStr containsString:name]) {
                    [outStr appendFormat:@"\n/// %@\n", des];
                    [outStr appendFormat:@"@property(nonatomic, copy) NSString *%@;\n", name];
                    
                }
            }
        } else if ([type isEqualToString:@"array[string]"]) {
            // links array[string] 链接
            
            NSString *des = muStrs[idx+1];
            if ([self hasChinese:des]) {
                // 是中文就说明这个字段有备注
                NSString *name = muStrs[idx-1];
                if (![outStr containsString:name]) {
                    [outStr appendFormat:@"\n/// %@\n", des];
                    [outStr appendFormat:@"@property(nonatomic, strong) NSArray<NSString *> *%@;\n", name];
                    
                }
            }
        }
    }];
    self.codeTextView.string = outStr;
    
}
@end
