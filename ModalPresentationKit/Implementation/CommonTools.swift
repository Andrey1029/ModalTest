//
//  CommonTools.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

import UIKit

extension UIView {
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners
        layer.masksToBounds = true
    }
}

extension UIScrollView {
    var scrollGestureRecognizers: [UIGestureRecognizer] {
        [panGestureRecognizer, pinchGestureRecognizer].compactMap { $0 }
    }
    
    var hasActiveGestures: Bool {
        scrollGestureRecognizers.map {
            switch $0.state {
            case .began, .changed, .possible:
                return true
            case .ended, .cancelled, .failed:
                return false
            @unknown default:
                return false
            }
        }.contains(true)
    }
}

extension DispatchQueue {
    static func onMainAsync(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
