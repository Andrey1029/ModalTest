//
//  ModalTransitioningDelegate.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

import UIKit

public final class ModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let observableHeight: ObservableModalHeight
    private let appearance: Appearance
    
    public init(observableHeight: ObservableModalHeight, appearance: Appearance = .init()) {
        self.observableHeight = observableHeight
        self.appearance = appearance
        super.init()
    }
    
    public convenience init(height: CGFloat = .infinity, appearance: Appearance = .init()) {
        self.init(observableHeight: .init(value: height), appearance: appearance)
    }
    
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        ModalPresentationController(
            presentedViewController: presented,
            presentingViewController: presenting,
            observableHeight: observableHeight,
            appearance: appearance
        )
    }
}
