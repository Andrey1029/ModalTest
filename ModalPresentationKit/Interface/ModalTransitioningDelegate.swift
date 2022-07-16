//
//  ModalTransitioningDelegate.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

import UIKit

public final class ModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let height: ModalHeight
    private let appearance: Appearance
    
    public init(height: ModalHeight, appearance: Appearance = .init()) {
        self.height = height
        self.appearance = appearance
        super.init()
    }
    
    public convenience init(height: CGFloat = .infinity, appearance: Appearance = .init()) {
        self.init(height: .init(value: height), appearance: appearance)
    }
    
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        ModalPresentationController(
            presentedViewController: presented,
            presentingViewController: presenting,
            height: height,
            appearance: appearance
        )
    }
}
