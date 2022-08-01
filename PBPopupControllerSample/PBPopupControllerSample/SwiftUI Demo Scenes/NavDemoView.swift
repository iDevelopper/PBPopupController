//
//  NavDemoView.swift
//  PBPopupController
//

import SwiftUI

@available(iOS 14.0, *)
struct NavDemoView : View {
    @State private var isPopupPresented: Bool = true
    @State private var isPopupHidden: Bool = false
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
                        Button("Show Bar") {
                            isPopupHidden = false
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
                        Button("Hide Bar") {
                            isPopupHidden = true
                        }
                    }
                }
                .navigationBarItems(trailing: Button("Close") {
                    onDismiss()
                })
        }
        .colorScheme(forcedColorScheme ?? environmentColorScheme)
        .navigationViewStyle(StackNavigationViewStyle())
        .popupDemo(isPresented: $isPopupPresented, isHidden: $isPopupHidden)
    }
}
