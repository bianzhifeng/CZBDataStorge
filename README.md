# CZBDataStorage

## 简介
数据存储工具, 封装了`UserDefaults` `KeychainSwift` `WCDB` `FileManager`功能, 实现一行代码进行数据持久化. 

## 功能

1. 提供UserDefaults沙盒存储.
2. 提供Keychain钥匙串存储.
3. 提供数据库存储.


## `UserDefaults`沙盒存储:

首先需要创建一个遵守`CZBUserDefaultsProtocol`协议的枚举, 在枚举中定义要存储的值得key. 示例如下所示:
```
enum UserDefaultKeys: String, CZBUserDefaultsProtocol {
  case month
  case day
}
```

存值:
```
CZBUserDefaults.standard[UserDefaultKeys.month] = "11月"
```
取值: 这里接口返回的是Any类型, 开发者自己转成确定的类型.
```
let month = CZBUserDefaults.standard[UserDefaultKeys.month]
```

## `Keychain`钥匙串存储:
首先需要创建一个遵守`CZBKeychainProtocol`协议的枚举, 在枚举中定义要存储的值得key. 示例如下所示:
```
enum ProfileKeys: String, CZBKeychainProtocol {
  case username
  case password
}
```

存值:
**注: 如果传入了除String Bool Data 类型之外的参数 代码停止执行**
```
CZBKeychain.standard[ProfileKeys.password] = "123"
```
取值: 这里接口返回的是Any类型, 开发者自己转成确定的类型.
```
let password = CZBKeychain.standard[ProfileKeys.password]
```


## 使`Model`直接操作数据库:
### 模型Model需遵守`CZBDbManagerProtocol`和`TableCodable`协议, 完成模型绑定. 例如:
```
class SampleTest: CZBDbManagerProtocol, TableCodable {

    var identifier: Int? = nil
    var description: String? = nil
    var offset: Int = 0
    var debugDescription: String? = nil

    enum CodingKeys: String, CodingTableKey {
        typealias Root = SampleTest
    static let objectRelationalMapping =   
        TableBinding(CodingKeys.self)
        case identifier = "id"
        case description
        case offset = "db_offset"
    }
}
```

### 插入一条数据
**注: 如想监听插入是否成功, 可接收返回值 true为成功 false 为失败.**
```
let sample = SampleTest()
sample.identifier = 10
sample.description = "这是一个测试用例"
sample.offset = 2
//把sample插入到数据库中
sample.insert()
```
### 插入一条数据(如已存在会被替换):
```
sample.insertOrReplace()
```
### 批量插入:
数组直接调用`insert()`执行批量插入操作, 需要数组中的`Element`遵守`CZBDbManagerProtocol`协议才能使用批量插入方法.
```
例:
[SampleTest(), SampleTest()].insert()
```
### 批量插入(如已存在会被替换):
```
[SampleTest(), SampleTest()].insertOrReplace()
```
### 删除操作
**参数注释**:
`where`: 判断语句 删除符合规定条件的结果
 `orderBy`: 把符合条件的结果按照identifier降序排列
`limit`: 删除几行
 `offset`: 从第几行开始删除
 `Returns`: 是否删除成功
 
这个函数做了什么呢? 获取`SampleTest`表中`description`为"这是一个测试用例"的数据集, 按`identifier`降序排列后的从第2行开始删除10条数据.
```
SampleTest.delete(where:
SampleTest.Properties.description.like("这是一个测试用例"),
orderBy: [SampleTest.Properties.identifier.asOrder(by: .descending)],
limit: 10,
offset: 1)
```
当然, 如果你只想删除表下边的所有数据你可以直接执行delete()
```
SampleTest.delete()
```

### 删除表
 `Returns`: 是否删除成功
```
SampleTest.deleteTable()
```

### 删除数据库
`Returns`: 是否删除成功
```
SampleTest.deleteDatabase()
```

### 更新操作
关于 `Condition [OrderBy] Limit Offset`的用法不再赘述
这里只说`[PropertyConvertible]`, 这个字段构成了部分插入/修改的操作, 如果传入了`[SampleTest.Properties.description]` 那么就只修改`description`的数据, 不传修改全部.
`Returns`: 是否更新成功.
```
接口声明:
sample.update(on: [PropertyConvertible],
              where: Condition?,
              orderBy: [OrderBy]?,
              limit: Limit?,
              offset: Offset?)
              
实例化一个SampleTest:
let sample = SampleTest()
sample.description = "我要修改description的内容"
```

### 下面是错误示范:
```
sample.update()
```
如果你只给类下的某几个属性赋值, 然后更新的时候直接使用`update()` 会造成你整个`SampleTest`表的所有数据被改造成你这个模型一样的数据, 拿上边例子来说, 我现在表里所有的行的`description`都变成了`"我要修改description的内容"`, 然而, 像`identifier/offset`这些都变成了默认值(默认值归结于你如何做的模型绑定 nil/空)

正确示范1: 如果你想改`SampleTest`表里所有行的`description`数据
```
sample.update(on: [SampleTest.Properties.description])
```
正确示范2: 想修改表里某些符合条件的选项
如: 更新表里`identifier`等于10 的行的`description`内容为`"我要修改description的内容"`
```
sample.update(on: [SampleTest.Properties.description], where: SampleTest.Properties.identifier == 10)
```
### 批量查找操作
`[PropertyConvertible]` 部分获取(获取指定某些属性的数据), 不传默认获取全部.
```
接口声明:
SampleTest.getObjects(on: [PropertyConvertible],
               where: Condition?,
               orderBy: [OrderBy]?,
               limit: Limit?,
               offset: Offset?)
```
例1: 获取`SampleTest`表下的`identifier` == 10的数据
```
SampleTest.getObjects(where: SampleTest.Properties.identifier == 10)
```
例2: 获取`SampleTest`表下的`description` == "我要修改description的内容"的数据
```
SampleTest.getObjects(where: SampleTest.Properties.description.like("我要修改description的内容"))
```
例3: 获取`SampleTest`表下的`description`含有"修改"的数据
```
SampleTest.getObjects(where: SampleTest.Properties.description.like("%修改%"))
```

### 查一条操作
```
接口声明:
getObject(
on propertyConvertibleList: [PropertyConvertible] = [],
where condition: Condition)
```
例:
```
SampleTest.getObject(where: SampleTest.Properties.identifier == 10)
```
**更多查询条件请查询SQL语句对比使用**.

### 值查询操作
获取`SampleTest`表中`identifier`的最大值
```
SampleTest.getValue(on: SampleTest.Properties.identifier.max())
```
获取`SampleTest`表中`identifier`的最小值
```
SampleTest.getValue(on: SampleTest.Properties.identifier.min())
```
获取`SampleTest`表中`第2行`的`identifier`值
```
SampleTest.getValue(on: SampleTest.Properties.identifier, offset: 1)
```
获取`SampleTest`表中`第3行`的`description`值
```
let value = SampleTest.getValue(on: SampleTest.Properties.description, offset: 2)
print(value?.stringValue)
```

## `CZBWCDBProtocol`进阶使用

### 加密:
**注1: 设置密码是一件很慎重的事情。对于已经创建且存在数据的数据库，无论是原本未加密想要改为加密，还是已经加密想要修改密码，都是成本非常高的操作，因此不要轻易使用。**
**注2: 设置加密接口应在其他所有调用(增删查改)之前进行，否则会因无法解密而出错。**
```
SampleTest.setCipher(password: "password")
```

### 开启事务
**注: 事务一般用于 `提升性能` 和 保证`数据原子性`。**
**注: 值得注意的一点, 关于`insert/insertOrReplace`操作, 内置了事务, 开发人员不必关心性能问题, 不需要手动开启事务, 删除/修改/获取操作可以使用事务来保证性能及数据原子性。**

例:
```
SampleTest.run {
   ///执行修改数据库操作
    sample.update()
}
```

## `CZBFileManager` 文件存储:

### with: `参数` 为文件名称.

### 存储`write`:
接口声明:
`fileName`: 文件名称
`file`: 要存储的文件(`Data/String/Dictionary/Array/UIImage`)
`result`: 是否存储成功(失败: 文件已存在或者不支持的文件类型)
```
@discardableResult
public func write(with fileName: String,
file: Any) -> Bool { }
```

1. 存储`String`:
```
CZBFileManager.shared.write(with: "saveTxt", file: "存储文字测试")
```
2. 存储`Dictionary`:
```
CZBFileManager.shared.write(with: "saveDict", file: ["key": "value"])
```
3. 存储`Array`: 
```
CZBFileManager.shared.write(with: "saveDictArray", file: [["key": "value"], ["key1": "value1"]])
```
4. 存储`Data`:
```
CZBFileManager.shared.write(with: "saveData", file: Data())
```
5. 存储`Image`:
```
CZBFileManager.shared.write(with: "saveImage", file: UIImage(named: "xxx")!)
```

### 读取 `read`
1. 读取`String/Image/Data`文件 
```
CZBFileManager.shared.read(with: "saveTxt")
```
2. 读取`Array`文件
```
CZBFileManager.shared.readArray(with: "saveDictArray")
```
3. 读取`Dictionary`文件
```
CZBFileManager.shared.readDictionary(with: "saveDict")
```

### 删除 `remove`
```
CZBFileManager.shared.remove(with: "saveTxt")
```

### 获取文件的大小 `getFileSize`返回值为`Double`类型,单位为`kb`
```
CZBFileManager.shared.getFileSize(with: "saveTxt")
```
