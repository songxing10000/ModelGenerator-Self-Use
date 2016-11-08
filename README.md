### update 2016.10.30

![](api.gif)

![](sosoapi to pro.gif)

![](sosoapi to postman.gif)

## Such data returned by the server

Field  | Type | Description |
:--:   | :--: | :--: |
id | int | 需求ID
title          | string |      需求标题
content        | string  |    需求内容
address        | string     | 地址信息
price          | string     | 价格
start          | string    |  开始时间
end            | string   |   结束时间
user           | array   |    发布者信息

## code blocks can improve the speed a little 
@property (nonatomic) <#type#> *<#name#>;
## But you have to copy the field name
 Field  | 
:--:   | 
id | 
title |        
content | 
address |
price |
start |
end |
user |
## The document has a description field, how can the code do not
 Description |
 :--: |
 需求ID |
需求标题 |
需求内容 |
地址信息 |
 价格 |
 开始时间 |
结束时间 |
发布者信息 |
## Nima one hundred field how to do this, also copy? ?


```objc
///  需求ID
@property (nonatomic) NSInteger id;

///  需求标题
@property (nonatomic) NSString  *title;

///  地址信息
@property (nonatomic) NSString  *address;

///  发布时间
@property (nonatomic) NSString  *created_at_format;

///  接单人数
@property (nonatomic) NSInteger book_num;

///  价格
@property (nonatomic) NSString  *price;

///  发布者信息
@property (nonatomic) NSArray   *user;
```


### But this particular array type, there may be a bunch of dictionary or dictionaries, unlike JSON array data as to know there are specific types, so for this array have to be processed manually
