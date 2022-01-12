//
//  UIViewPreview.swift
//  PBPopupController
//
//  Created by Patrick BODET on 06/10/2020.
//  Copyright © 2020-2022 Patrick BODET. All rights reserved.
//

import UIKit

#if canImport(SwiftUI)
import SwiftUI
@available(iOS 13.0, *)
struct UIViewPreview<View: UIView>: UIViewRepresentable {
    let view: View
    
    init(_ builder: @escaping () -> View) {
        view = builder()
    }
    
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
#endif
