//
//  ModalPresentationView.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, *)
struct ModalPresentationView<Content: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = ModalPresentationControllerWrapper<Content>
    
    let isPresented: Binding<Bool>
    let height: CGFloat
    let appearance: Appearance
    let content: () -> Content
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init()
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context _: Context
    ) {
        uiViewController.model = .init(
            content: content,
            onDismiss: { isPresented.wrappedValue = false },
            isModalPresented: isPresented.wrappedValue,
            height: height,
            appearance: appearance
        )
    }
}

#endif
