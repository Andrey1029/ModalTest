//
//  ObservableModalHeight.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

import CoreGraphics

protocol ObservableModalHeightDelegate: AnyObject {
    func heightChanged(animated: Bool)
}

public final class ObservableModalHeight {
    weak var delegate: ObservableModalHeightDelegate?
    
    public private(set) var value: CGFloat
    
    public func update(newValue: CGFloat, animated: Bool) {
        guard newValue != value else { return }
        value = newValue
        
        DispatchQueue.onMainAsync { [weak delegate] in
            delegate?.heightChanged(animated: animated)
        }
    }
    
    public init(value: CGFloat) {
        self.value = value
    }
}
