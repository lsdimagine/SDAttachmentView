//
//  ViewController.swift
//  SDAttachmentView
//
//  Created by Shidong Lin on 9/4/20.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {

    private let textView = UITextView()
    private let parser = SDTextParser()

    private let attachedViews = NSMapTable<SDAttachmentView, UIView>.strongToStrongObjects()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.addSubview(textView)

        textView.font = UIFont.systemFont(ofSize: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            textView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        textView.delegate = self
        textView.layoutManager.delegate = self
        textView.textStorage.delegate = self
    }

    func textViewDidChange(_ textView: UITextView) {
        let results = parser.parse(textView.text)
        print(results)
        guard let mutableAttributedText = textView.attributedText.mutableCopy() as? NSMutableAttributedString else {
            return
        }
        for result in results {
            let text = textView.text[textView.text.index(textView.text.startIndex, offsetBy: result.location)..<textView.text.index(textView.text.startIndex, offsetBy: result.location + result.length)]
            let pillView = MatchedPillView(String(text))
            let attachment = SDAttachmentView(pillView)
            mutableAttributedText.replaceCharacters(in: NSRange(location: result.location, length: result.length), with: NSAttributedString.init(attachment: attachment))
        }
        textView.attributedText = mutableAttributedText
    }

    private func updateAttachedSubviews() {
        // Collect all SubviewTextAttachment attachments
        let subviewAttachments = textView.textStorage.subviewAttachmentRanges.map { $0.attachment }

        var attachmentsToRemove = [SDAttachmentView]()
        for attachment in attachedViews.keyEnumerator() {
            if !subviewAttachments.contains(attachment as! SDAttachmentView) {
                attachmentsToRemove.append(attachment as! SDAttachmentView)
            }
        }
        // Insert views that became attached
        let attachmentsToAdd = subviewAttachments.filter {
            attachedViews.object(forKey: $0) == nil
        }
        for attachment in attachmentsToAdd {
            let view = attachment.customView

            textView.addSubview(view)
            attachedViews.setObject(view, forKey: attachment)
        }

        for attachment in attachmentsToRemove {
            let view = attachment.customView
            view.removeFromSuperview()
            attachedViews.removeObject(forKey: attachment)
        }
    }

    private func layoutAttachedSubviews() {
        let layoutManager = textView.layoutManager
        let scaleFactor = textView.window?.screen.scale ?? UIScreen.main.scale

        // For each attached subview, find its associated attachment and position it according to its text layout
        let attachmentRanges = textView.textStorage.subviewAttachmentRanges
        for (attachment, range) in attachmentRanges {
            guard let view = self.attachedViews.object(forKey: attachment) else {
                // A view for this provider is not attached yet??
                continue
            }
            guard view.superview === textView else {
                // Skip views which are not inside the text view for some reason
                continue
            }
            guard let attachmentRect = boundingRect(forAttachmentCharacterAt: range.location, layoutManager: layoutManager) else {
                // Can't determine the rectangle for the attachment: just hide it
                view.isHidden = true
                continue
            }

            let convertedRect = convertRectFromTextContainer(attachmentRect)
            let integralRect = CGRect(origin: convertedRect.origin.integral(withScaleFactor: scaleFactor),
                                      size: convertedRect.size)

            DispatchQueue.main.async {
                view.frame = integralRect
                view.isHidden = false
            }
        }
    }

    private func boundingRect(forAttachmentCharacterAt characterIndex: Int, layoutManager: NSLayoutManager) -> CGRect? {
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSMakeRange(characterIndex, 1), actualCharacterRange: nil)
        let glyphIndex = glyphRange.location
        guard glyphIndex != NSNotFound && glyphRange.length == 1 else {
            return nil
        }

        let attachmentSize = layoutManager.attachmentSize(forGlyphAt: glyphIndex)
        guard attachmentSize.width > 0.0 && attachmentSize.height > 0.0 else {
            return nil
        }

        let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)
        let glyphLocation = layoutManager.location(forGlyphAt: glyphIndex)
        guard lineFragmentRect.width > 0.0 && lineFragmentRect.height > 0.0 else {
            return nil
        }

        return CGRect(origin: CGPoint(x: lineFragmentRect.minX + glyphLocation.x,
                                      y: lineFragmentRect.minY + glyphLocation.y - attachmentSize.height),
                      size: attachmentSize)
    }

    func convertRectFromTextContainer(_ rect: CGRect) -> CGRect {
        let insets = textView.textContainerInset
        return rect.offsetBy(dx: insets.left, dy: insets.top)
    }
}

extension ViewController: NSLayoutManagerDelegate {
    public func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
            if layoutFinishedFlag {
                self.layoutAttachedSubviews()
            }
        }
}

extension ViewController: NSTextStorageDelegate {
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
            if editedMask.contains(.editedAttributes) {
                self.updateAttachedSubviews()
            }
        }
}

private extension CGPoint {

    func integral(withScaleFactor scaleFactor: CGFloat) -> CGPoint {
        guard scaleFactor > 0.0 else {
            return self
        }

        return CGPoint(x: round(self.x * scaleFactor) / scaleFactor,
                       y: round(self.y * scaleFactor) / scaleFactor)
    }

}

private extension NSAttributedString {

    var subviewAttachmentRanges: [(attachment: SDAttachmentView, range: NSRange)] {
        var ranges = [(SDAttachmentView, NSRange)]()

        let fullRange = NSRange(location: 0, length: self.length)
        self.enumerateAttribute(NSAttributedString.Key.attachment, in: fullRange) { value, range, _ in
            if let attachment = value as? SDAttachmentView {
                ranges.append((attachment, range))
            }
        }

        return ranges
    }

}

