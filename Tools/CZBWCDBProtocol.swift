//
//  CZBWCDBAble.swift
//  CZBDataPersistence
//
//  Created by 边智峰 on 2018/11/8.
//  Copyright © 2018 边智峰. All rights reserved.
//

import Foundation
import WCDBSwift

public protocol CZBDbManagerProtocol {
    var dbName: String { get }
}

public extension CZBDbManagerProtocol where Self: TableCodable {
    var dbName: String {
        return "\(Self.self)"
    }
    
    /// 插入操作
    ///
    /// - Parameters:
    ///   - propertyConvertibleList: 部分插入? 例如 Sample.Properties.identifier
    /// - Returns: 是否成功
    @discardableResult
    public func insert(
        on propertyConvertibleList: [PropertyConvertible]? = nil) -> Bool {
        return DBManager.shared.insert(with: [self],
                                       on: propertyConvertibleList, with: dbName)
    }
    
    /// 插入操作(如果已经存在那么替换)
    ///
    /// - Parameters:
    ///   - propertyConvertibleList: 部分插入? 例如 Sample.Properties.identifier
    /// - Returns: 是否成功
    @discardableResult
    public func insertOrReplace(
        on propertyConvertibleList: [PropertyConvertible]? = nil) -> Bool {
        return DBManager.shared.insertOrReplace(with: [self],
                                                on: propertyConvertibleList, with: dbName)
    }
    
    
    /// 删除操作 如只设置表名 表示需要删除整个表的数据
    ///
    /// - Parameters:
    ///   - condition: 符合删除的条件
    ///   - orderList: 排序的方式
    ///   - limit: 删除的个数
    ///   - offset: 从第几个开始删除
    /// - Returns: 是否成功
    @discardableResult
    public static func delete(where condition: Condition? = nil,
                              orderBy orderList: [OrderBy]? = nil,
                              limit: Limit? = nil,
                              offset: Offset? = nil) -> Bool {
        
        return DBManager.shared.delete(with: "\(Self.self)",
            from: "\(Self.self)",
            where: condition,
            orderBy: orderList,
            limit: limit,
            offset: offset)
    }
    
    /// 删除该类对应的表
    ///
    /// - Returns: 是否成功
    @discardableResult
    public static func deleteTable() -> Bool {
        return DBManager.deleteTable(with: "\(Self.self)",
            from: "\(Self.self)")
    }
    
    /// 删除数据库
    ///
    /// - Returns: 是否成功
    @discardableResult
    public static func deleteDatabase() -> Bool {
        return DBManager.deleteDatabase(with: "\(Self.self)")
    }
    
    
    /// 更新操作
    ///
    /// - Parameters:
    ///   - propertyConvertibleList: 要修改的字段
    ///   - object: 根据这个object得内容修改
    ///   - condition: 符合修改的条件
    ///   - orderList: 排序方式
    ///   - limit: 删除的个数
    ///   - offset: 从第几个开始删除
    @discardableResult
    public func update(
        on propertyConvertibleList: [PropertyConvertible] = [],
        where condition: Condition? = nil,
        orderBy orderList: [OrderBy]? = nil,
        limit: Limit? = nil,
        offset: Offset? = nil) -> Bool {
        
        
        return DBManager.shared.update(with: dbName,
                                       from: dbName,
                                       on: propertyConvertibleList,
                                       with: self,
                                       where: condition,
                                       orderBy: orderList,
                                       limit: limit,
                                       offset: offset)
    }
    
    /// 获取操作
    ///
    /// - Parameters:
    ///   - propertyConvertibleList: 部分获取某些字段 如不传 取全部
    ///   - condition: 符合查询的条件
    ///   - orderList: 排序方式
    ///   - limit: 删除的个数
    ///   - offset: 从符合条件的列表第几个开始删除
    /// - Returns: 结果
    public static func getObjects(
        on propertyConvertibleList: [PropertyConvertible] = [],
        where condition: Condition? = nil,
        orderBy orderList: [OrderBy]? = nil,
        limit: Limit? = nil,
        offset: Offset? = nil) -> [Self]? {
        
        return DBManager.shared.get(with: "\(Self.self)",
            from: "\(Self.self)",
            on: propertyConvertibleList,
            where: condition,
            orderBy: orderList,
            limit: limit,
            offset: offset)
    }
    
    /// 获取单个对象
    ///
    /// - Parameters:
    ///   - propertyConvertibleList: 部分获取某些字段 如不传 取全部
    ///   - condition: 符合查询的条件
    /// - Returns: 结果
    public static func getObject(
        on propertyConvertibleList: [PropertyConvertible] = [],
        where condition: Condition) -> Self? {
        
        return DBManager.shared.get(with: "\(Self.self)",
            from: "\(Self.self)",
            on: propertyConvertibleList,
            where: condition,
            limit: 1)?.first
    }
    
    /// 值查询
    ///
    /// - Parameters:
    ///   - propertyConvertible: 要获取的值对应的属性
    ///   - condition: 符合查询的条件
    ///   - orderList: 排序方式
    ///   - limit: 查询的个数
    ///   - offset: 查询的列表的第几个开始获取
    /// - Returns: 结果
    public static func getValue(
        on propertyConvertible: ColumnResultConvertible,
        where condition: Condition? = nil,
        orderBy orderList: [OrderBy]? = nil,
        limit: Limit? = nil,
        offset: Offset? = nil) -> FundamentalValue? {
        
        return DBManager.shared.getValue(with: "\(Self.self)",
            from: "\(Self.self)",
            on: propertyConvertible,
            where: condition,
            orderBy: orderList,
            limit: limit,
            offset: offset)
    }
    
    /// 开启一个事务
    ///
    /// - Parameter transaction: 事务执行模块
    public static func run(transaction: () -> Void) {
        return DBManager.run(with: "\(Self.self)", transaction: transaction)
    }
    
    /// 设置密码 (如果要给数据库设置密码 那么此方法要在增删查改之前执行, 否则会因为无法解密出错)
    ///
    /// - Parameter password: 密码
    public static func setCipher(password: String) {
        let data = password.data(using: .ascii)
        DBManager.setCipher(with: "\(Self.self)", key: data)
    }
}

// MARK: - 为数组添加扩展让其存在直接操作数据库的方法
public extension Array where Element: CZBDbManagerProtocol & TableCodable {
    
    
    /// 插入数据
    ///
    /// - Parameter propertyConvertibleList: 要插入的字段 不传默认全部插入
    @discardableResult
    func insert(on propertyConvertibleList: [PropertyConvertible]? = nil) -> Bool {
        return DBManager.shared.insert(with: self,
                                       on: propertyConvertibleList,
                                       with: "\(Element.self)")
    }
    
    /// 插入数据(如果已经存在那么替换)
    ///
    /// - Parameter propertyConvertibleList: 要插入的字段 不传默认全部插入
    @discardableResult
    func insertOrReplace(on propertyConvertibleList: [PropertyConvertible]? = nil) -> Bool {
        return DBManager.shared.insertOrReplace(with: self,
                                                on: propertyConvertibleList,
                                                with: "\(Element.self)")
    }
    
}

