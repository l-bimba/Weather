//
//  BottomPopupDismissInteractionController.swift
//  Weather
//
//  Created by Lukas Bimba on 7/3/20.
//  Copyright © 2020 Lukas Bimba. All rights reserved.
//

import UIKit

class BottomPopupDismissInteractionController: UIPercentDrivenInteractiveTransition {

    private let kMinPercentOfVisiblePartToCompleteAnimation = CGFloat(0.5)
    private weak var presentedViewController: BottomPopupViewController?
    private var currentPercent: CGFloat = 0
    private weak var transitioningDelegate: BottomPopupTransitionHandler?
    
    init(presentedViewController: BottomPopupViewController?) {
        self.presentedViewController = presentedViewController
        self.transitioningDelegate = presentedViewController?.transitioningDelegate as? BottomPopupTransitionHandler
        super.init()
        preparePanGesture(in: presentedViewController?.view)
    }
    
    private func finishAnimation() {
        if currentPercent > kMinPercentOfVisiblePartToCompleteAnimation {
            finish()
        } else {
            cancel()
        }
    }
    
    private func preparePanGesture(in view: UIView?) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        presentedViewController?.view?.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        let translationY = pan.translation(in: presentedViewController?.view).y
        currentPercent = min(max(translationY/(presentedViewController?.view.frame.size.height ?? 0), 0), 1)
        
        switch pan.state {
        case .began:
            transitioningDelegate?.isInteractiveDismissStarted = true
            presentedViewController?.dismiss(animated: true, completion: nil)
        case .changed:
            update(currentPercent)
        default:
            transitioningDelegate?.isInteractiveDismissStarted = false
            finishAnimation()
        }
    }
}
