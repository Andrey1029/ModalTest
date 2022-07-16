//
//  ModalContentWrapper.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, *)
final class ModalContentWrapper<Content: View>: UIHostingController<Content> {
    private let onDismiss: () -> Void
    
    init(content: Content, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(rootView: content)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss()
    }
}

#endif
