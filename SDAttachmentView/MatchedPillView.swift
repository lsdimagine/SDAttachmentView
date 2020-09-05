//
//  MatchedPillView.swift
//  SDAttachmentView
//
//  Created by Shidong Lin on 9/4/20.
//

import UIKit

class MatchedPillView: UIView {
    private let label = UILabel()

    init(_ text: String) {
        super.init(frame: .zero)
        addSubview(label)
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        backgroundColor = .black
        layer.cornerRadius = 4.0
        let rect = label.intrinsicContentSize

//        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        frame = CGRect(x: 0, y: 0, width: rect.width + 10, height: rect.height)
    }

    @available(*, unavailable, message: "Not implemented")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
