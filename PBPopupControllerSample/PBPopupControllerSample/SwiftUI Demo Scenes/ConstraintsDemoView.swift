//
//  SafeAreaDemoView.swift
//  PBPopupController
//

import SwiftUI

@available(iOS 14.0, *)
struct MarqueeLabelCustomView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> MarqueeLabel {
        let marqueeLabel = MarqueeLabel(frame: .zero, rate: 15, fadeLength: 10)
        marqueeLabel.leadingBuffer = 0.0
        marqueeLabel.trailingBuffer = 5.0
        marqueeLabel.animationDelay = 1.0
        marqueeLabel.type = .continuous
        return marqueeLabel
    }

    func updateUIView(_ uiView: MarqueeLabel, context: Context) {
        uiView.text = text
    }
}

@available(iOS 14.0.0, *)
struct SafeAreaDemoView : View {
    let includeLink: Bool
    let offset: Bool
    
    init(includeLink: Bool = false, offset: Bool = false) {
        self.includeLink = includeLink
        self.offset = offset
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack {
                Text("Top").offset(x: offset ? 40.0 : 0.0)
                Spacer()
                Text("Center")
                Spacer()
                Text("Bottom")
            }.frame(minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .top)
            if includeLink {
                NavigationLink("Next ▸", destination: SafeAreaDemoView(includeLink: includeLink).navigationTitle("PBPopupUI"))
                    .padding()
            }
        }
        //.padding(4)
        .font(.system(.headline))
    }
}

@available(iOS 14.0.0, *)
extension View {
    func popupDemo(isPresented: Binding<Bool>, isHidden: Binding<Bool>? = nil) -> some View {
        return self.popup(isPresented: isPresented, isHidden: isHidden, willPresent: { print("Will Present Bar") }, onPresent: { print("Bar Presented") }, onDismiss: { print("Bar Dismissed") }, willOpen: { print("Will Open Popup") },  onOpen: { print("Popup Opened") }, onClose: { print("Popup Closed") }) {
            SafeAreaDemoView(offset: true)
                .popupLabel(MarqueeLabel(), sublabel: MarqueeLabel())
            
                .popupTitle(LoremIpsum.title, subtitle: LoremIpsum.sentence)
            
                .popupImage(Image("Cover23").resizable())
            
                .popupBarItems(trailing: {
                    HStack(spacing: 20) {
                        Button(action: {
                            print("Play")
                        }) {
                            Image(systemName: "play.fill")
                        }
                        
                        Button(action: {
                            print("Next")
                        }) {
                            Image(systemName: "forward.fill")
                        }
                    }
                    .font(.system(size: 20))
                })
        }
        .isFloating(true)
        //.floatingBackgroundColor(.cyan)
        //.popupBarStyle(.compact)
        //.popupCloseButtonStyle(.round)
        //.popupPresentationStyle(.fullScreen)
        //.popupPresentationStyle(.custom)
        //.popupContentSize(CGSize(width: -1, height: 500))
        .popupPresentationDuration(0.35)
        .popupIgnoreDropShadowView(false)
    }
}
