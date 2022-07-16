//
//  State.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 15.07.2022.
//

import CoreGraphics

struct State: Equatable {
    struct Input: Equatable {
        enum Context {
            case common
            case draggingFinish
            case normalHeightChange
        }
        
        let bounds: CGRect
        let translation: CGFloat
        let normalHeight: CGFloat
        let velocity: CGFloat
        let scrollOffsets: [CGFloat]
        let unnecessaryTranslation: CGFloat
        let context: Context
    }
    
    let frame: CGRect
    let backgroundAlpha: CGFloat
    let animated: Bool
    let unnecessaryTranslation: CGFloat
    let resetMinScrollOffset: Bool
    
    static func makeState(input: Input) -> Self? {
        let normalHeight = min(input.bounds.height, input.normalHeight)
        
        guard
            normalHeight != .zero,
            canDrag(
                translation: input.translation - input.unnecessaryTranslation,
                scrollOffsets: input.scrollOffsets
            )
        else {
            return makeDefaultState(
                bounds: input.bounds,
                normalHeight: normalHeight,
                unnecessaryTranslation: input.context == .draggingFinish
                    ? .zero
                    : input.translation,
                resetMinScrollOffset: false,
                animated: false
            )
        }
        
        let finalTranslation = input.translation - input.unnecessaryTranslation
        
        switch input.context {
        case .common:
            return makeCommonState(
                animated: false,
                bounds: input.bounds,
                translation: finalTranslation,
                normalHeight: normalHeight,
                unnecessaryTranslation: input.unnecessaryTranslation
            )
        case .draggingFinish:
            return makeDraggingFinishState(
                bounds: input.bounds,
                translation: finalTranslation,
                velocity: input.velocity,
                normalHeight: normalHeight
            )
        case .normalHeightChange:
            return makeCommonState(
                animated: true,
                bounds: input.bounds,
                translation: finalTranslation,
                normalHeight: normalHeight,
                unnecessaryTranslation: input.unnecessaryTranslation
            )
        }
    }
}

private extension State {
    static func canDrag(
        translation: CGFloat,
        scrollOffsets: [CGFloat]
    ) -> Bool {
        guard let minScrollOffset = scrollOffsets.min() else { return true }
        return minScrollOffset <= translation
    }
    
    static func makeCommonState(
        animated: Bool,
        bounds: CGRect,
        translation: CGFloat,
        normalHeight: CGFloat,
        unnecessaryTranslation: CGFloat
    ) -> Self {
        translation < 0
            ? makeDefaultState(
                bounds: bounds,
                normalHeight: normalHeight,
                unnecessaryTranslation: unnecessaryTranslation,
                resetMinScrollOffset: true,
                animated: animated
            )
            : .init(
                bounds: bounds,
                normalHeight: normalHeight,
                additionalTopInset: translation,
                additionalHeight: .zero,
                unnecessaryTranslation: unnecessaryTranslation,
                resetMinScrollOffset: true,
                animated: animated
            )
    }
    
    static func makeDraggingFinishState(
        bounds: CGRect,
        translation: CGFloat,
        velocity: CGFloat,
        normalHeight: CGFloat
    ) -> Self? {
        let dismissOffset = normalHeight * dismissOffsetCoefficient
        guard translation < dismissOffset && velocity < minVelocityForClosing else { return nil }
        return makeDefaultState(
            bounds: bounds,
            normalHeight: normalHeight,
            unnecessaryTranslation: .zero,
            resetMinScrollOffset: true,
            animated: true
        )
    }
    
    static func makeDefaultState(
        bounds: CGRect,
        normalHeight: CGFloat,
        unnecessaryTranslation: CGFloat,
        resetMinScrollOffset: Bool,
        animated: Bool
    ) -> Self {
        .init(
            bounds: bounds,
            normalHeight: normalHeight,
            additionalTopInset: .zero,
            additionalHeight: .zero,
            unnecessaryTranslation: unnecessaryTranslation,
            resetMinScrollOffset: resetMinScrollOffset,
            animated: animated
        )
    }
    
    init(
        bounds: CGRect,
        normalHeight: CGFloat,
        additionalTopInset: CGFloat,
        additionalHeight: CGFloat,
        unnecessaryTranslation: CGFloat,
        resetMinScrollOffset: Bool,
        animated: Bool
    ) {
        self.resetMinScrollOffset = resetMinScrollOffset
        self.unnecessaryTranslation = unnecessaryTranslation
        self.animated = animated
        self.backgroundAlpha = additionalTopInset > 0
            ? 1 - additionalTopInset / normalHeight
            : 1
        self.frame = .init(
            x: bounds.minX,
            y: bounds.maxY - normalHeight + additionalTopInset,
            width: bounds.width,
            height: normalHeight + additionalHeight
        )
    }
}

/// dismiss offset = modal screen normal height * dismissOffsetCoefficient
private let dismissOffsetCoefficient: CGFloat = 0.35
private let minVelocityForClosing: CGFloat = 1250
