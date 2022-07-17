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
    private var unnecessaryTranslation: CGFloat = .zero
    private let activeScrollViewsStorage = ActiveScrollViewsStorage()
    private var isActive = false
    
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
        updateState(context: .common, animated: false)
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
        isActive = true
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        isActive = false
        
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
        updateState(context: .common, animated: true)
    }
}

private extension ModalPresentationController {
    var translation: CGFloat {
        panGestureRecognizer.translation(in: containerView).y
    }
    
    var velocity: CGFloat {
        panGestureRecognizer.velocity(in: containerView).y
    }
    
    var scrollOffsets: [Int: CGFloat] {
        .init(
            uniqueKeysWithValues: activeScrollViewsStorage.scrollViews.map {
                ($0.hashValue, $0.contentOffset.y)
            }
        )
    }
    
    func getCurrentState() -> State? {
        isActive
            ? .init(
                frame: presentedView?.frame ?? .zero,
                backgroundAlpha: backgroundView.alpha,
                unnecessaryTranslation: unnecessaryTranslation,
                scrollOffsets: scrollOffsets
            )
            : nil
    }
    
    @objc func didPan() {
        switch panGestureRecognizer.state {
        case .began, .changed, .possible:
            updateState(context: .common, animated: false)
        case .ended, .cancelled, .failed:
            updateState(context: .draggingFinish, animated: true)
            panGestureRecognizer.setTranslation(.zero, in: containerView)
        @unknown default:
            break
        }
        
        activeScrollViewsStorage.update()
    }
    
    @objc func closeWindow() {
        presentedViewController.dismiss(animated: true)
    }
    
    func updateState(context: State.Input.Context, animated: Bool) {
        let input = makeStateInput(context: context)
        let newState = State.makeState(input: input)
        let oldState = getCurrentState()
        
        guard newState != oldState else { return }
        
        guard let newState = newState else {
            closeWindow()
            return
        }
        
        unnecessaryTranslation = newState.unnecessaryTranslation
        updateScrollViewsOffsets(newState: newState, oldState: oldState)
        updateViews(newState: newState, oldState: oldState, animated: animated)
    }
    
    func updateViews(newState: State, oldState: State?, animated: Bool) {
        let updateViews = { [weak self] in
            self?.presentedView?.frame = newState.frame
            self?.backgroundView.alpha = newState.backgroundAlpha
        }
        
        print()
        
        guard
            newState.frame != oldState?.frame
                || newState.backgroundAlpha != oldState?.backgroundAlpha
        else { return }
        
        guard animated, isActive else {
            updateViews()
            return
        }
        
        UIView.animate(
            withDuration: 0.25,
            delay: .zero,
            options: [.allowUserInteraction, .curveEaseInOut],
            animations: updateViews
        )
    }
    
    func updateScrollViewsOffsets(newState: State, oldState: State?) {
        guard newState.scrollOffsets != oldState?.scrollOffsets else { return }
        
        newState.scrollOffsets.forEach { item in
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
            scrollOffsets: scrollOffsets,
            unnecessaryTranslation: unnecessaryTranslation,
            context: context
        )
    }
}
