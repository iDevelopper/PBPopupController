//
//  CustomBarView.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 11/10/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import SwiftUI
import MapKit

@available(iOS 14.0, *)
struct EnlargingButton: View {
    let label: String
    let action: (Bool) -> Void
    @State var pressed: Bool = false
    
    init(label: String, perform action: @escaping (Bool) -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        return Text(label)
            .font(.title)
            .foregroundColor(.white)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.blue))
            .scaleEffect(self.pressed ? 1.2 : 1.0)
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                withAnimation(.easeInOut) {
                    self.pressed = pressing
                    self.action(pressing)
                }
            }, perform: { })
    }
}

@available(iOS 14.0, *)
struct CustomBarView: View {
    @Environment(\.colorScheme) var colorScheme
    
    static private let center = CLLocationCoordinate2D(latitude: 48.8534, longitude: 2.3488)
    static private let defaultRegion = MKCoordinateRegion(center: CustomBarView.center, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    static private let zoomedRegion = MKCoordinateRegion(center: CustomBarView.center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    @State private var region = CustomBarView.defaultRegion
    
    let popupContentController: UIViewController
    
    private let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        
        popupContentController = PBUIKitPopupContentController()
    }
    
    @State var input: String = ""
    @State var isOpen: Bool = false
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            Map(coordinateRegion: $region)
                .ignoresSafeArea()
                .animation(.easeInOut)
            Button(action: {
                onDismiss()
            }, label: {
                Image(systemName: "chevron.left")
                    .renderingMode(.template)
                    .font(.title2)
            })
            .buttonStyle(MyButtonStyle(colorScheme: colorScheme))
            .padding()
        }
        .popup(isPresented: Binding.constant(true), isOpen: $isOpen, tapGestureShouldBegin: { state in
            return true
        }, panGestureShouldBegin: { state in
            if state == .open {
                return true
            }
            return false
        }, popupContentController: popupContentController)
        .inheritsVisualStyleFromBottomBar(false)
        //.isTranslucent(false)
        //.backgroundColor(.white)
        .backgroundEffect(UIBlurEffect(style: .systemThinMaterial))
        .shouldExtendCustomBarUnderSafeArea(true)
        .popupBarCustomView() {
            ZStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    EnlargingButton(label: "Zoom") { pressing in
                        self.region = pressing ? CustomBarView.zoomedRegion : CustomBarView.defaultRegion
                    }.padding()
                    Spacer()
                }
                Button(action: {
                    isOpen.toggle()
                }, label: {
                    Image(systemName: "chevron.up")
                        .renderingMode(.template)
                })
                .buttonStyle(MyButtonStyle(colorScheme: colorScheme))
                .padding()
            }
            //.background(Color.white)
        }
    }
}

@available(iOS 14.0, *)
struct MyButtonStyle: ButtonStyle {
    let colorScheme: ColorScheme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title2)
            .frame(width: 15, height: 15, alignment: .center)
            .padding(10)
            .foregroundColor(.white)
            .background(configuration.isPressed ? Color(red: 116 / 255.0, green: 185 / 255.0, blue: 1.0) : Color.blue)
            .cornerRadius(10.0)
    }
    
}

@available(iOS 14.0, *)
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        CustomBarView(onDismiss: {})
    }
}
