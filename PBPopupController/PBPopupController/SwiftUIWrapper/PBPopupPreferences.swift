//
//  PBPopupPreferences.swift
//  PBPopupController
//
//  Created by Patrick BODET on 08/10/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import SwiftUI
import UIKit

@available(iOS 13.0, *)
internal struct PBPopupTitleData : Equatable {
    let title: String
    let subtitle: String?
}

internal struct PBPopupLabelData : Equatable {
    let label: UILabel?
    let sublabel: UILabel?
}

@available(iOS 13.0, *)
internal struct PBPopupAnyViewWrapper : Equatable {
    let anyView: AnyView
    
    static func == (lhs: PBPopupAnyViewWrapper, rhs: PBPopupAnyViewWrapper) -> Bool {
        return false
    }
}

@available(iOS 13.0, *)
internal struct PBPopupTitlePreferenceKey: PBPopupNullablePreferenceKey {
    typealias Value = PBPopupTitleData?
}

@available(iOS 13.0, *)
internal struct PBPopupLabelPreferenceKey: PBPopupNullablePreferenceKey {
    typealias Value = PBPopupLabelData?
}

@available(iOS 13.0, *)
internal struct PBPopupImagePreferenceKey: PBPopupNullablePreferenceKey {
    typealias Value = Image?
}

@available(iOS 13.0, *)
internal struct PBPopupProgressPreferenceKey: PBPopupNullablePreferenceKey {
    typealias Value = Float?
}

@available(iOS 13.0, *)
internal struct PBPopupLeadingBarItemsPreferenceKey: PBPopupNullablePreferenceKey {
    typealias Value = PBPopupAnyViewWrapper?
}

@available(iOS 13.0, *)
internal struct PBPopupTrailingBarItemsPreferenceKey: PBPopupNullablePreferenceKey {
    typealias Value = PBPopupAnyViewWrapper?
}

@available(iOS 13.0, *)
internal protocol PBPopupNullablePreferenceKey : PreferenceKey {
    static var defaultValue: Value? {
        get
    }
}

@available(iOS 13.0, *)
internal extension PBPopupNullablePreferenceKey {
    static var defaultValue: Value? {
        get {
            return nil
        }
    }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
