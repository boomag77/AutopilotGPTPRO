

import UIKit

final class PurchasePresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }
        
        let containerBounds = containerView.bounds
        let contentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        return CGRect(x: 0, y: containerBounds.height - contentSize.height, width: containerBounds.width, height: contentSize.height)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: min(400, parentSize.height / 2)) // Customize this as needed
    }
    
}
