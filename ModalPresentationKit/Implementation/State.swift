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
        let scrollOffsets: [Int: CGFloat]
        let unnecessaryTranslation: CGFloat
        let context: Context
    }
    
    let frame: CGRect
    let backgroundAlpha: CGFloat
    let animated: Bool
    let unnecessaryTranslation: CGFloat
    let scrollOffsetsChanges: [Int: CGFloat]
    
    static func makeState(input: Input) -> Self? {
        let normalHeight = min(input.bounds.height, input.normalHeight)
        let finalTranslation = input.translation - input.unnecessaryTranslation
        var scrollOffsetsChanges = [Int: CGFloat]()
        
        guard
            normalHeight != .zero,
            canDrag(
                translation: finalTranslation,
                scrollOffsets: input.scrollOffsets,
                scrollOffsetsChanges: &scrollOffsetsChanges
            )
        else {
            return makeDefaultState(
                bounds: input.bounds,
                normalHeight: normalHeight,
                unnecessaryTranslation: input.context == .draggingFinish
                    ? .zero
                    : input.translation,
                animated: false,
                scrollOffsetsChanges: scrollOffsetsChanges
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
                scrollOffsetsChanges: scrollOffsetsChanges
            )
        case .draggingFinish:
            return makeDraggingFinishState(
                bounds: input.bounds,
                translation: finalTranslation,
                velocity: input.velocity,
                normalHeight: normalHeight,
                scrollOffsetsChanges: scrollOffsetsChanges
            )
        case .normalHeightChange:
            return makeCommonState(
                animated: true,
                bounds: input.bounds,
                translation: finalTranslation,
                normalHeight: normalHeight,
                unnecessaryTranslation: input.unnecessaryTranslation,
                scrollOffsetsChanges: scrollOffsetsChanges
            )
        }
    }
}

private extension State {
    static func canDrag(
        translation: CGFloat,
        scrollOffsets: [Int: CGFloat],
        scrollOffsetsChanges: inout [Int: CGFloat]
    ) -> Bool {
        guard let minScrollOffset = scrollOffsets.min(by: { $0.value < $1.value })
        else { return true }
        
        let canDrag = minScrollOffset.value <= translation

        if canDrag {
            scrollOffsetsChanges[minScrollOffset.key] = .zero
        }
        
        return canDrag
    }
    
    static func makeCommonState(
        animated: Bool,
        bounds: CGRect,
        translation: CGFloat,
        normalHeight: CGFloat,
        unnecessaryTranslation: CGFloat,
        scrollOffsetsChanges: [Int: CGFloat]
    ) -> Self {
        translation < 0
            ? makeDefaultState(
                bounds: bounds,
                normalHeight: normalHeight,
                unnecessaryTranslation: unnecessaryTranslation,
                animated: animated,
                scrollOffsetsChanges: scrollOffsetsChanges
            )
            : .init(
                bounds: bounds,
                normalHeight: normalHeight,
                additionalTopInset: translation,
                additionalHeight: .zero,
                unnecessaryTranslation: unnecessaryTranslation,
                animated: animated,
                scrollOffsetsChanges: scrollOffsetsChanges
            )
    }
    
    static func makeDraggingFinishState(
        bounds: CGRect,
        translation: CGFloat,
        velocity: CGFloat,
        normalHeight: CGFloat,
        scrollOffsetsChanges: [Int: CGFloat]
    ) -> Self? {
        let dismissOffset = normalHeight * dismissOffsetCoefficient
        guard translation < dismissOffset && velocity < minVelocityForClosing else { return nil }
        return makeDefaultState(
            bounds: bounds,
            normalHeight: normalHeight,
            unnecessaryTranslation: .zero,
            animated: true,
            scrollOffsetsChanges: scrollOffsetsChanges
        )
    }
    
    static func makeDefaultState(
        bounds: CGRect,
        normalHeight: CGFloat,
        unnecessaryTranslation: CGFloat,
        animated: Bool,
        scrollOffsetsChanges: [Int: CGFloat]
    ) -> Self {
        .init(
            bounds: bounds,
            normalHeight: normalHeight,
            additionalTopInset: .zero,
            additionalHeight: .zero,
            unnecessaryTranslation: unnecessaryTranslation,
            animated: animated,
            scrollOffsetsChanges: scrollOffsetsChanges
        )
    }
    
    init(
        bounds: CGRect,
        normalHeight: CGFloat,
        additionalTopInset: CGFloat,
        additionalHeight: CGFloat,
        unnecessaryTranslation: CGFloat,
        animated: Bool,
        scrollOffsetsChanges: [Int: CGFloat]
    ) {
        self.scrollOffsetsChanges = scrollOffsetsChanges
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
