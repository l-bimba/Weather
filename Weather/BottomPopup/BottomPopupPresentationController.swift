//
//  BottomPopupPresentationController.swift
//  Weather
//
//  Created by Lukas Bimba on 7/3/20.
//  Copyright © 2020 Lukas Bimba. All rights reserved.
//

import UIKit

class BottomPopupPresentationController: UIPresentationController {

    fileprivate var dimmingView: UIView!
    fileprivate var popupHeight: CGFloat
    let kDimmingViewVisibleAlpha = CGFloat(0.8)
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            return CGRect(origin: CGPoint(x: 0, y: UIScreen.main.bounds.size.height - popupHeight), size: CGSize(width: presentedViewController.view.frame.size.width, height: popupHeight))
        }
    }
    
    private func changeDimmingViewAlphaAlongWithAnimation(to alpha: CGFloat) {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = alpha
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = alpha
        })
    }
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, usingHeight height: CGFloat) {
        self.popupHeight = height
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        changeDimmingViewAlphaAlongWithAnimation(to: kDimmingViewVisibleAlpha)
    }
    
    override func dismissalTransitionWillBegin() {
        changeDimmingViewAlphaAlongWithAnimation(to: 0)
    }
    
    @objc fileprivate func handleTap(_ tap: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}

private extension BottomPopupPresentationController {
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: kDimmingViewVisibleAlpha)
        dimmingView.alpha = 0.0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        dimmingView.isUserInteractionEnabled = true
        dimmingView.addGestureRecognizer(tapGesture)
    }
}
