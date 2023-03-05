//
//  SceneSelection.swift
//  PBPopupController
//

import SwiftUI

@available(iOS 14.0, *)
struct SceneSelection: View {
    @State var tabnavPresented: Bool = false
    @State var tabPresented: Bool = false
    @State var navPresented: Bool = false
    @State var viewPresented: Bool = false
    @State var viewSheetPresented: Bool = false
    @State var mapSheetPresented: Bool = false
    @State var musicSheetPresented: Bool = false
    let onDismiss: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Standard Scenes")) {
                    Button("Tab View + Navigation View") {
                        tabnavPresented.toggle()
                    }
                    .foregroundColor(Color(.label))
                    .fullScreenCover(isPresented: $tabnavPresented, content: {
                        TabNavView {
                            tabnavPresented.toggle()
                        }
                    })
                    Button("Tab View") {
                        tabPresented.toggle()
                    }
                    .foregroundColor(Color(.label))
                    .fullScreenCover(isPresented: $tabPresented, content: {
                        TabDemoView {
                            tabPresented.toggle()
                        }
                    })
                    Button("Navigation View") {
                        navPresented.toggle()
                    }
                    .foregroundColor(Color(.label))
                    .fullScreenCover(isPresented: $navPresented, content: {
                        NavDemoView {
                            navPresented.toggle()
                        }
                    })
                    Button("Navigation View (Sheet)") {
                        viewSheetPresented.toggle()
                    }
                    .foregroundColor(Color(.label))
                    .sheet(isPresented: $viewSheetPresented, content: {
                        NavDemoView {
                            viewSheetPresented.toggle()
                        }
                    })
                    Button("View") {
                        viewPresented.toggle()
                    }
                    .foregroundColor(Color(.label))
                    .fullScreenCover(isPresented: $viewPresented, content: {
                        ViewDemoView() {
                            viewPresented.toggle()
                        }
                    })
                }
                Section(header: Text("Custom Popup Bar")) {
                    Button("Custom Popup Bar + UIKit Popup Content Controller") {
                        mapSheetPresented.toggle()
                    }
                    .foregroundColor(Color(.label))
                    .fullScreenCover(isPresented: $mapSheetPresented, content: {
                        CustomBarView {
                            mapSheetPresented.toggle()
                        }
                    })
                }
                Section(header: Text("Demo App")) {
                    Button("Apple Music") {
                        musicSheetPresented.toggle()
                    }
                    .foregroundColor(Color(.label))
                    .fullScreenCover(isPresented: $musicSheetPresented, content: {
                        MusicView {
                            musicSheetPresented.toggle()
                        }
                    })
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("PBPopupUI")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Home") {
                onDismiss()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .ignoresSafeArea()
    }
}
