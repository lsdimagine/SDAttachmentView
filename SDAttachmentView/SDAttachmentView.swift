//
//  SDAttachmentView.swift
//  SDAttachmentView
//
//  Created by Shidong Lin on 9/4/20.
//

import UIKit

class SDAttachmentView: NSTextAttachment {
    let customView: UIView

    init(_ view: UIView) {
        customView = view
        super.init(data: nil, ofType: nil)
    }

    @available(*, unavailable, message: "Not implemented")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        return nil
    }

    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        customView.setNeedsLayout()
        customView.layoutIfNeeded()
        return customView.bounds
    }
}
