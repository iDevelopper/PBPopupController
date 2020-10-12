//
//  TabNavView.swift
//  PBPopupController
//

import SwiftUI

@available(iOS 14.0.0, *)
struct InnerNavView : View {
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            SafeAreaDemoView(includeLink: true)
                .navigationBarTitle("Tab View + Navigation View")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("Close") {
                    onDismiss()
                })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

@available(iOS 14.0.0, *)
struct TabNavView : View {
    @State private var isPopupPresented: Bool = true
    private let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        TabView{
            InnerNavView(onDismiss: onDismiss)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Tab")
                }
            InnerNavView(onDismiss: onDismiss)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Tab")
                }
            InnerNavView(onDismiss: onDismiss)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Tab")
                }
            InnerNavView(onDismiss: onDismiss)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Tab")
                }
        }
        .popupDemo(isPresented: $isPopupPresented)
    }
}

@available(iOS 14.0.0, *)
struct TabNavView_Previews: PreviewProvider {
    static var previews: some View {
        TabNavView(onDismiss: {})
    }
}
