//
//  UIViewControllerPreview.swift
//  PBPopupController
//
//  Created by Patrick BODET on 06/10/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import UIKit

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }

    // MARK: - UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> ViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<UIViewControllerPreview<ViewController>>) {
        return
    }
}
#endif
