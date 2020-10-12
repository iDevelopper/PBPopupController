//
//  PBPopupEnvironment.swift
//  PBPopupController
//
//  Created by Patrick BODET on 08/10/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import SwiftUI

internal struct PBPopupBarStyleKey: EnvironmentKey {
    static let defaultValue: PBPopupBarStyle = .default
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

@available(iOS 13.0, *)
internal struct PBPopupBarCustomViewKey: EnvironmentKey {
    static let defaultValue: PBPopupBarCustomView? = nil
}

@available(iOS 13.0, *)
internal extension EnvironmentValues {
    var popupCloseButtonStyle: PBPopupCloseButtonStyle {
        get { self[PBPopupCloseButtonStyleKey.self] }
        set { self[PBPopupCloseButtonStyleKey.self] = newValue }
    }
    
    var popupBarStyle: PBPopupBarStyle {
        get { self[PBPopupBarStyleKey.self] }
        set { self[PBPopupBarStyleKey.self] = newValue }
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

    var popupBarCustomBarView: PBPopupBarCustomView? {
        get { self[PBPopupBarCustomViewKey.self] }
        set { self[PBPopupBarCustomViewKey.self] = newValue }
    }
    
}
