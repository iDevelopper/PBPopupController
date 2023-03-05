//
//  PBPopupEnvironment.swift
//  PBPopupController
//
//  Created by Patrick BODET on 08/10/2020.
//  Copyright © 2020-2022 Patrick BODET. All rights reserved.
//

import SwiftUI

internal struct PBPopupBarStyleKey: EnvironmentKey {
    static let defaultValue: PBPopupBarStyle = .default
}

internal struct PBPopupBarBarStyleKey: EnvironmentKey {
    static let defaultValue: UIBarStyle = .default
}

@available(iOS 14.0, *)
internal struct PBPopupBarBackgroundStyleKey: EnvironmentKey {
    static let defaultValue: UIBlurEffect.Style = .systemMaterial
}

internal struct PBPopupBarBackgroundEffectKey: EnvironmentKey {
    static let defaultValue: UIBlurEffect? = nil
}

internal struct PBPopupBarInheritsVisualStyleFromBottomBarKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

internal struct PBPopupBarIsTranslucentKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

internal struct PBPopupBarBackgroundColorKey: EnvironmentKey {
    static let defaultValue: UIColor? = nil
}

internal struct PBPopupBarBarTintColorKey: EnvironmentKey {
    static let defaultValue: UIColor? = nil
}

internal struct PBPopupCloseButtonStyleKey: EnvironmentKey {
    static let defaultValue: PBPopupCloseButtonStyle = .default
}

internal struct PBPopupBarProgressViewStyleKey: EnvironmentKey {
    static let defaultValue: PBPopupBarProgressViewStyle = .default
}

internal struct PBPopupBarBorderViewStyleKey: EnvironmentKey {
    static let defaultValue: PBPopupBarBorderViewStyle = .default
}

internal struct PBPopupPresentationStyleKey: EnvironmentKey {
    static let defaultValue: PBPopupPresentationStyle = .default
}

internal struct PBPopupPresentationDurationKey: EnvironmentKey {
    static let defaultValue: TimeInterval = 0.5
}

internal struct PBPopupDismissalDurationKey: EnvironmentKey {
    static let defaultValue: TimeInterval = 0.6
}

internal struct PBPopupCompletionThresholdKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0.3
}

internal struct PBPopupCompletionFlickMagnitudeKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1200
}

internal struct PBPopupContentSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

internal struct PBPopupIgnoreDropShadowViewKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

internal struct PBPopupShouldExtendCustomBarUnderSafeAreaKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

@available(iOS 14.0, *)
internal struct PBPopupBarCustomViewKey: EnvironmentKey {
    static let defaultValue: PBPopupBarCustomView? = nil
}

@available(iOS 14.0, *)
internal extension EnvironmentValues {
    var popupCloseButtonStyle: PBPopupCloseButtonStyle {
        get { self[PBPopupCloseButtonStyleKey.self] }
        set { self[PBPopupCloseButtonStyleKey.self] = newValue }
    }
    
    var popupBarStyle: PBPopupBarStyle {
        get { self[PBPopupBarStyleKey.self] }
        set { self[PBPopupBarStyleKey.self] = newValue }
    }
    
    var barStyle: UIBarStyle {
        get { self[PBPopupBarBarStyleKey.self] }
        set { self[PBPopupBarBarStyleKey.self] = newValue }
    }
    
    var backgroundStyle: UIBlurEffect.Style {
        get { self[PBPopupBarBackgroundStyleKey.self] }
        set { self[PBPopupBarBackgroundStyleKey.self] = newValue }
    }
    
    var backgroundEffect: UIBlurEffect? {
        get { self[PBPopupBarBackgroundEffectKey.self] }
        set { self[PBPopupBarBackgroundEffectKey.self] = newValue }
    }
    
    var inheritsVisualStyleFromBottomBar: Bool {
        get { self[PBPopupBarInheritsVisualStyleFromBottomBarKey.self] }
        set { self[PBPopupBarInheritsVisualStyleFromBottomBarKey.self] = newValue }
    }
    
    var isTranslucent: Bool {
        get { self[PBPopupBarIsTranslucentKey.self] }
        set { self[PBPopupBarIsTranslucentKey.self] = newValue }
    }
    
    var backgroundColor: UIColor? {
        get { self[PBPopupBarBackgroundColorKey.self] }
        set { self[PBPopupBarBackgroundColorKey.self] = newValue }
    }
    
    var barTintColor: UIColor? {
        get { self[PBPopupBarBarTintColorKey.self] }
        set { self[PBPopupBarBarTintColorKey.self] = newValue }
    }
    
    var popupBarProgressViewStyle: PBPopupBarProgressViewStyle {
        get { self[PBPopupBarProgressViewStyleKey.self] }
        set { self[PBPopupBarProgressViewStyleKey.self] = newValue }
    }
    
    var popupBarBorderViewStyle: PBPopupBarBorderViewStyle {
        get { self[PBPopupBarBorderViewStyleKey.self] }
        set { self[PBPopupBarBorderViewStyleKey.self] = newValue }
    }
    
    var popupPresentationStyle: PBPopupPresentationStyle {
        get { self[PBPopupPresentationStyleKey.self] }
        set { self[PBPopupPresentationStyleKey.self] = newValue }
    }
    
    var popupPresentationDuration: TimeInterval {
        get { self[PBPopupPresentationDurationKey.self] }
        set { self[PBPopupPresentationDurationKey.self] = newValue }
    }
    
    var popupDismissalDuration: TimeInterval {
        get { self[PBPopupDismissalDurationKey.self] }
        set { self[PBPopupDismissalDurationKey.self] = newValue }
    }
    
    var popupCompletionThreshold: CGFloat {
        get { self[PBPopupCompletionThresholdKey.self] }
        set { self[PBPopupCompletionThresholdKey.self] = newValue }
    }
    
    var popupCompletionFlickMagnitude: CGFloat {
        get { self[PBPopupCompletionFlickMagnitudeKey.self] }
        set { self[PBPopupCompletionFlickMagnitudeKey.self] = newValue }
    }
    
    var popupContentSize: CGSize {
        get { self[PBPopupContentSizeKey.self] }
        set { self[PBPopupContentSizeKey.self] = newValue }
    }
    
    var popupIgnoreDropShadowView: Bool {
        get { self[PBPopupIgnoreDropShadowViewKey.self] }
        set { self[PBPopupIgnoreDropShadowViewKey.self] = newValue }
    }
    
    var shouldExtendCustomBarUnderSafeArea: Bool {
        get { self[PBPopupShouldExtendCustomBarUnderSafeAreaKey.self] }
        set { self[PBPopupShouldExtendCustomBarUnderSafeAreaKey.self] = newValue }
    }
    
    var popupBarCustomBarView: PBPopupBarCustomView? {
        get { self[PBPopupBarCustomViewKey.self] }
        set { self[PBPopupBarCustomViewKey.self] = newValue }
    }
}
