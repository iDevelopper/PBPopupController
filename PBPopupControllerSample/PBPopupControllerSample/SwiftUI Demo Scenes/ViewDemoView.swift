//
//  ViewDemoView.swift
//  PBPopupController
//

import SwiftUI

@available(iOS 14.0, *)
struct ViewDemoView : View {
    @State private var isPopupPresented: Bool = true
    let onDismiss: () -> Void
    
    var body: some View {
        InnerView(onDismiss: onDismiss)
            .popupDemo(isPresented: $isPopupPresented)
    }
}
