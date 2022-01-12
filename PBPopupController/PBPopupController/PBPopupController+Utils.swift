//
//  PBPopupController+Utils.swift
//  CarPlayTest
//
//  Created by Patrick BODET on 30/10/2021.
//

import Foundation


internal func _PBPopupDecodeBase64String(base64String: String?) -> String? {
    if let data = Data(base64Encoded: base64String ?? "", options: []) {
        return String(data: data, encoding: .utf8)
    }
    return nil
}

