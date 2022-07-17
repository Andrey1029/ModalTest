//
//  UIViewController+Extensions.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

import UIKit

public extension UIViewController {
    func presentModal(
        vc: UIViewController,
        observableHeight: ObservableModalHeight,
        animated: Bool = true,
        appearance: Appearance = .init(),
        completion: (() -> Void)? = nil
    ) {
        let delegate = ModalTransitioningDelegate(
            observableHeight: observableHeight,
            appearance: appearance
        )
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = delegate
        present(vc, animated: animated, completion: completion)
    }
    
    func presentModal(
        vc: UIViewController,
        height: CGFloat = .infinity,
        animated: Bool = true,
        appearance: Appearance = .init(),
        completion: (() -> Void)? = nil
    ) {
        presentModal(
            vc: vc,
            observableHeight: .init(value: height),
            animated: animated,
            appearance: appearance,
            completion: completion
        )
    }
}
