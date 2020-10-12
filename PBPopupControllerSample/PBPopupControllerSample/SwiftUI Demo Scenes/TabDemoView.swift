//
//  TabDemoView.swift
//  PBPopupController
//

import SwiftUI

@available(iOS 14.0.0, *)
struct InnerView : View {
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            SafeAreaDemoView()
            Button("Close") {
                onDismiss()
            }.padding()
            //.edgesIgnoringSafeArea(.all)
        }
    }
}

@available(iOS 14.0.0, *)
struct TabDemoView : View {
    @State private var isPopupPresented: Bool = true
    private let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        TabView{
            InnerView(onDismiss: onDismiss)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Tab")
                }
            InnerView(onDismiss: onDismiss)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Tab")
                }
            InnerView(onDismiss: onDismiss)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Tab")
                }
            InnerView(onDismiss: onDismiss)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Tab")
                }
        }
        .popupDemo(isPresented: $isPopupPresented)
    }
}
