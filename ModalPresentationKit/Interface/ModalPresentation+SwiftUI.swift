//
//  ModalPresentation+SwiftUI.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, *)
public extension View {
    func modalView<Content: View>(
        isPresented: Binding<Bool>,
        height: CGFloat = .infinity,
        animatedHeightChanges: Bool = true,
        appearance: Appearance = .init(),
        content: @escaping () -> Content
    ) -> some View {
        let view = ModalPresentationView(
            isPresented: isPresented,
            height: height,
            animatedHeightChanges: animatedHeightChanges,
            appearance: appearance,
            content: content
        ).disabled(true)
        
        return background(view)
    }
}

#endif
