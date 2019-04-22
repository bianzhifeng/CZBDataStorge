//
//  CZBUserDefaults.swift
//  CZBDataPersistence
//
//  Created by 边智峰 on 2018/11/5.
//  Copyright © 2018 边智峰. All rights reserved.
//

import Foundation


/// CZBUserDefaultsProtocol 协议
public protocol CZBUserDefaultsProtocol  {
    var uniqueKey: String { get }
}
///限定 为String类型 赋值uniqueKey为命名空间 + value 防止key值重复
public extension CZBUserDefaultsProtocol where Self: RawRepresentable, Self.RawValue == String {
    var uniqueKey: String {
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        return namespace + "." + "\(rawValue)"
    }
}

/// 重写subscript方法 为CZBUserDefaults添加下标赋值法
public class CZBUserDefaults {
    
    private let defaultStand = UserDefaults.standard
    
    public static let standard = CZBUserDefaults()
    private init() { }
    
    public subscript(key: CZBUserDefaultsProtocol) -> Any? {
        set {
            defaultStand.set(newValue, forKey: key.uniqueKey)
        }
        get {
            return defaultStand.value(forKey: key.uniqueKey)
        }
    }
}
