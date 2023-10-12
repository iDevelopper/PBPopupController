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
            .inheritsVisualStyleFromBottomBar(false)
            .popupBarCustomizer { popupBar in
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .right
                paragraphStyle.lineBreakMode = .byTruncatingTail
                
                popupBar.titleTextAttributes = [ .paragraphStyle: paragraphStyle, .font: UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont(name: "Chalkduster", size: 14)!), .foregroundColor: UIColor.green ]
                popupBar.subtitleTextAttributes = [ .paragraphStyle: paragraphStyle, .font: UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: UIFont(name: "Chalkduster", size: 12)!), .foregroundColor: UIColor.cyan ]
                popupBar.tintColor = .systemGreen
            }
    }
}
