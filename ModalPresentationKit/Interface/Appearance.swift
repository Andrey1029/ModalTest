//
//  Appearance.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

import UIKit

public struct Appearance {
    public let backgroundColor: UIColor
    public let cornerRadius: CGFloat
    
    public init(
        backgroundColor: UIColor = .black.withAlphaComponent(0.3),
        cornerRadius: CGFloat = 20
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
}
