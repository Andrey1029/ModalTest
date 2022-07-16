//
//  ModalPresentationControllerWrapper.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, *)
final class ModalPresentationControllerWrapper<Content: View>: UIViewController {
    struct Model {
        let content: () -> Content
        let onDismiss: () -> Void
        let isModalPresented: Bool
        let height: CGFloat
        let appearance: Appearance
    }
    
    private lazy var height = ModalHeight(value: .zero)
    
    var model: Model? {
        didSet {
            guard let model = model else { return }
            height.value = model.height
            
            guard oldValue?.isModalPresented != model.isModalPresented else { return }
            
            guard model.isModalPresented else {
                presentedViewController?.dismiss(animated: true, completion: model.onDismiss)
                return
            }
            
            presentModal(
                vc: ModalContentWrapper(
                    content: model.content(),
                    onDismiss: model.onDismiss
                ),
                height: height,
                animated: true,
                appearance: model.appearance,
                completion: nil
            )
        }
    }
}

#endif
