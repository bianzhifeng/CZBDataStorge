//
//  CZBKeyChain.swift
//  CZBDataPersistence
//
//  Created by 边智峰 on 2018/11/5.
//  Copyright © 2018 边智峰. All rights reserved.
//

import Foundation
import KeychainSwift

/// CZBUserDefaultsProtocol 协议
public protocol CZBKeychainProtocol  {
    var uniqueKey: String { get }
}
///限定 为String类型 赋值uniqueKey为命名空间 + value 防止key值重复
public extension CZBKeychainProtocol where Self: RawRepresentable, Self.RawValue == String {
    var uniqueKey: String {
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        return namespace + "." + "\(rawValue)"
    }
}

/// 重写subscript方法 为CZBKeychain添加下标赋值法
public class CZBKeychain {
    
    private lazy var keychain: KeychainSwift = {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        return keychain
    }()
    
    /// 只支持存储String Data Bool 其他类型会保存失败
    public static let standard = CZBKeychain()
    private init() { }
    
    public subscript(key: CZBKeychainProtocol) -> Any? {
        set {
            if let newValue = newValue as? String {
                keychain.set(newValue, forKey: key.uniqueKey)
                return
            }
            if let newValue = newValue as? Bool {
                keychain.set(newValue, forKey: key.uniqueKey)
                return
            }
            if let newValue = newValue as? Data {
                keychain.set(newValue, forKey: key.uniqueKey)
                return
            }
            assert(false, "请传入可被保存的类型 类型限定为 String/Bool/Data")
        }
        get {
            if let value = keychain.get(key.uniqueKey), value != "\u{01}", value != "\0", value != "" {
                return value
            }
            if let value = keychain.getBool(key.uniqueKey) {
                return value
            }
            if let value = keychain.getData(key.uniqueKey) {
                return  value
            }
            return nil
        }
    }
}
