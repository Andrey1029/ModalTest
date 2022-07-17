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
        }
        
        let bounds: CGRect
        let translation: CGFloat
        let normalHeight: CGFloat
        let velocity: CGFloat
        let scrollOffsets: [Int: CGFloat]
        let unnecessaryTranslation: CGFloat
        let context: Context
    }
    
    let frame: CGRect
    let backgroundAlpha: CGFloat
    let unnecessaryTranslation: CGFloat
    let scrollOffsets: [Int: CGFloat]
    
    static func makeState(input: Input) -> Self? {
        let normalHeight = min(input.bounds.height, input.normalHeight)
        let finalTranslation = input.translation - input.unnecessaryTranslation
        var scrollOffsets = input.scrollOffsets
        
        guard
            normalHeight != .zero,
            canDrag(
                translation: finalTranslation,
                scrollOffsets: &scrollOffsets
            )
        else {
            return makeDefaultState(
                bounds: input.bounds,
                normalHeight: normalHeight,
                unnecessaryTranslation: input.context == .draggingFinish
                    ? .zero
                    : input.translation,
                scrollOffsets: scrollOffsets
            )
        }
        
        switch input.context {
        case .common:
            return makeCommonState(
                animated: false,
                bounds: input.bounds,
                translation: finalTranslation,
                normalHeight: normalHeight,
                unnecessaryTranslation: input.unnecessaryTranslation,
                scrollOffsets: scrollOffsets
            )
        case .draggingFinish:
            return makeDraggingFinishState(
                bounds: input.bounds,
                translation: finalTranslation,
                velocity: input.velocity,
                normalHeight: normalHeight,
                scrollOffsets: scrollOffsets
            )
        }
    }
}

private extension State {
    static func canDrag(
        translation: CGFloat,
        scrollOffsets: inout [Int: CGFloat]
    ) -> Bool {
        guard let minScrollOffset = scrollOffsets.min(by: { $0.value < $1.value })
        else { return true }
        
        let canDrag = minScrollOffset.value <= translation

        if canDrag {
            scrollOffsets[minScrollOffset.key] = .zero
        }
        
        return canDrag
    }
    
    static func makeCommonState(
        animated: Bool,
        bounds: CGRect,
        translation: CGFloat,
        normalHeight: CGFloat,
        unnecessaryTranslation: CGFloat,
        scrollOffsets: [Int: CGFloat]
    ) -> Self {
        translation < 0
            ? makeDefaultState(
                bounds: bounds,
                normalHeight: normalHeight,
                unnecessaryTranslation: unnecessaryTranslation,
                scrollOffsets: scrollOffsets
            )
            : .init(
                bounds: bounds,
                normalHeight: normalHeight,
                additionalTopInset: translation,
                additionalHeight: .zero,
                unnecessaryTranslation: unnecessaryTranslation,
                scrollOffsets: scrollOffsets
            )
    }
    
    static func makeDraggingFinishState(
        bounds: CGRect,
        translation: CGFloat,
        velocity: CGFloat,
        normalHeight: CGFloat,
        scrollOffsets: [Int: CGFloat]
    ) -> Self? {
        let dismissOffset = normalHeight * dismissOffsetCoefficient
        guard translation < dismissOffset && velocity < minVelocityForClosing else { return nil }
        return makeDefaultState(
            bounds: bounds,
            normalHeight: normalHeight,
            unnecessaryTranslation: .zero,
            scrollOffsets: scrollOffsets
        )
    }
    
    static func makeDefaultState(
        bounds: CGRect,
        normalHeight: CGFloat,
        unnecessaryTranslation: CGFloat,
        scrollOffsets: [Int: CGFloat]
    ) -> Self {
        .init(
            bounds: bounds,
            normalHeight: normalHeight,
            additionalTopInset: .zero,
            additionalHeight: .zero,
            unnecessaryTranslation: unnecessaryTranslation,
            scrollOffsets: scrollOffsets
        )
    }
    
    init(
        bounds: CGRect,
        normalHeight: CGFloat,
        additionalTopInset: CGFloat,
        additionalHeight: CGFloat,
        unnecessaryTranslation: CGFloat,
        scrollOffsets: [Int: CGFloat]
    ) {
        self.scrollOffsets = scrollOffsets
        self.unnecessaryTranslation = unnecessaryTranslation
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
