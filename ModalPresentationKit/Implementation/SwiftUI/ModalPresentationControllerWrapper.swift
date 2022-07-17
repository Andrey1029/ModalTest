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
        let animatedHeightChanges: Bool
        let appearance: Appearance
    }
    
    private lazy var observableHeight = ObservableModalHeight(value: .zero)
    
    var model: Model? {
        didSet {
            guard let model = model else { return }
            
            observableHeight.update(
                newValue: model.height,
                animated: model.animatedHeightChanges
            )
            
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
                observableHeight: observableHeight,
                animated: true,
                appearance: model.appearance,
                completion: nil
            )
        }
    }
}

#endif
