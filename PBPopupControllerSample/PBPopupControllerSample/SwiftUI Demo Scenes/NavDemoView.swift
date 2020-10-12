//
//  NavDemoView.swift
//  PBPopupController
//

import SwiftUI

@available(iOS 14.0, *)
struct NavDemoView : View {
    @State private var isPopupPresented: Bool = true
    let onDismiss: () -> Void
    @Environment(\.colorScheme) private var environmentColorScheme
    @State private var forcedColorScheme: ColorScheme?
    
    var body: some View {
        NavigationView {
            SafeAreaDemoView(includeLink: true)
                .navigationBarTitle("Navigation View")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Present Bar") {
                            isPopupPresented = true
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button("Appearance") {
                            if let forcedColorScheme = forcedColorScheme {
                                self.forcedColorScheme = forcedColorScheme == .dark ? .light : .dark
                            } else {
                                forcedColorScheme = environmentColorScheme == .dark ? .light : .dark
                            }
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button("Dismiss Bar") {
                            isPopupPresented = false
                        }
                    }
                }
                .navigationBarItems(trailing: Button("Close") {
                    onDismiss()
                })
        }
        .colorScheme(forcedColorScheme ?? environmentColorScheme)
        .navigationViewStyle(StackNavigationViewStyle())
        .popupDemo(isPresented: $isPopupPresented)
    }
}
