//
//  ModalPresentationController.swift
//  ModalPresentationKit
//
//  Created by Andrey Golubenko on 16.07.2022.
//

import UIKit

final class ModalPresentationController: UIPresentationController {
    private let height: ModalHeight
    private let appearance: Appearance
    private var animationsEnabled = false
    private var unnecessaryTranslation: CGFloat = .zero
    private let activeScrollViewsStorage = ActiveScrollViewsStorage()
    
    private var stateInput: State.Input? {
        didSet {
            guard let stateInput = stateInput, oldValue != stateInput else { return }
            state = State.makeState(input: stateInput)
        }
    }
    
    private var state: State? {
        didSet {
            guard
                oldValue != state || !(state?.scrollOffsetsChanges.isEmpty ?? true)
            else { return }
            
            stateUpdated()
        }
    }
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = appearance.backgroundColor
        view.alpha = 0
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(closeWindow))
        )
        return view
    }()
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        recognizer.delegate = self
        return recognizer
    }()
    
    init(
        presentedViewController: UIViewController,
        presentingViewController: UIViewController?,
        height: ModalHeight,
        appearance: Appearance
    ) {
        self.height = height
        self.appearance = appearance
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        height.delegate = self
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
        presentedViewController.view.roundCorners(
            [.layerMinXMinYCorner, .layerMaxXMinYCorner],
            radius: appearance.cornerRadius
        )
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        backgroundView.frame = containerView?.bounds ?? .zero
        stateInput = makeStateInput(context: .common)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        containerView?.addSubview(backgroundView)
        containerView?.addSubview(presentedViewController.view)
        
        presentingViewController.transitionCoordinator?.animate { [weak backgroundView] context in
            backgroundView?.alpha = 1
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        animationsEnabled = true
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        coordinator.animate { [weak backgroundView] _ in
            backgroundView?.alpha = 0
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        backgroundView.removeFromSuperview()
        presentedViewController.view.removeFromSuperview()
    }
}

extension ModalPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard
            let scrollView = otherGestureRecognizer.view as? UIScrollView,
            scrollView.scrollGestureRecognizers.contains(otherGestureRecognizer)
        else {
            return false
        }
        
        activeScrollViewsStorage.scrollViews.insert(scrollView)
        return true
    }
}

extension ModalPresentationController: ModalHeightDelegate {
    func heightChanged() {
        stateInput = makeStateInput(context: .normalHeightChange)
    }
}

private extension ModalPresentationController {
    var translation: CGFloat {
        panGestureRecognizer.translation(in: containerView).y
    }
    
    var velocity: CGFloat {
        panGestureRecognizer.velocity(in: containerView).y
    }
    
    @objc func didPan() {
        switch panGestureRecognizer.state {
        case .began, .changed, .possible:
            stateInput = makeStateInput(context: .common)
        case .ended, .cancelled, .failed:
            stateInput = makeStateInput(context: .draggingFinish)
            panGestureRecognizer.setTranslation(.zero, in: containerView)
        @unknown default:
            break
        }
        
        activeScrollViewsStorage.update()
    }
    
    @objc func closeWindow() {
        presentedViewController.dismiss(animated: true)
    }
    
    func stateUpdated() {
        guard let state = state else {
            closeWindow()
            return
        }
        
        unnecessaryTranslation = state.unnecessaryTranslation
        updateScrollViewsOffsets(state: state)
        guard state.animated, animationsEnabled else {
            updateViews(state: state)
            return
        }
        
        UIView.animate(
            withDuration: 0.25,
            delay: .zero,
            options: [.allowUserInteraction, .curveEaseInOut],
            animations: { [weak self] in
                self?.updateViews(state: state)
            }
        )
    }
    
    func updateViews(state: State) {
        presentedView?.frame = state.frame
        backgroundView.alpha = state.backgroundAlpha
    }
    
    func updateScrollViewsOffsets(state: State) {
        state.scrollOffsetsChanges.forEach { item in
            let scrollView = activeScrollViewsStorage
                .scrollViews.first { $0.hashValue == item.key }
            scrollView?.contentOffset.y = item.value
        }
    }
    
    func makeStateInput(context: State.Input.Context) -> State.Input {
        State.Input(
            bounds: containerView.map {
                CGRect(
                    x: $0.bounds.minX,
                    y: $0.bounds.minY + $0.safeAreaInsets.top,
                    width: $0.bounds.width,
                    height: $0.bounds.height - $0.safeAreaInsets.top
                )
            } ?? .zero,
            translation: translation,
            normalHeight: height.value,
            velocity: velocity,
            scrollOffsets: .init(
                uniqueKeysWithValues: activeScrollViewsStorage.scrollViews.map {
                    ($0.hashValue, $0.contentOffset.y)
                }
            ),
            unnecessaryTranslation: unnecessaryTranslation,
            context: context
        )
    }
}
