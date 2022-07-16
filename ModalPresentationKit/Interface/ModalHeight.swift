//
//  ModalHeight.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

import CoreGraphics

protocol ModalHeightDelegate: AnyObject {
    func heightChanged()
}

public final class ModalHeight {
    weak var delegate: ModalHeightDelegate?
    
    public var value: CGFloat {
        didSet {
            guard oldValue != value else { return }
            delegate?.heightChanged()
        }
    }
    
    public init(value: CGFloat) {
        self.value = value
    }
}
