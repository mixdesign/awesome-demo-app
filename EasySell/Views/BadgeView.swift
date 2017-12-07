//
// Created by Almas Adilbek on 12/2/17.
// Copyright (c) 2017 GOOD/APP. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class BadgeView : UIView {

    private let textLabel:UILabel = {
        return UILabel.base().font(.boldSystemFont(ofSize: 9)).color(.white)
    }()
    let backgroundView = UIView()

    var horizontalPadding:CGFloat = 3 {
        didSet {
            layoutTextLabel()
        }
    }

    var verticalPadding:CGFloat = 2 {
        didSet {
            layoutTextLabel()
        }
    }

    var letterSpacing:CGFloat = 0 {
        didSet {
            textLabel.setLetter(spacing: letterSpacing)
        }
    }

    var text:String = "" {
        didSet {
            textLabel.text = text
            textLabel.setLetter(spacing: letterSpacing)
        }
    }

    var textColor:UIColor = .white {
        didSet {
            textLabel.textColor = textColor
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configUI()
    }

    init(text:String = "") {
        super.init(frame:.zero)
        self.text = text
        configUI()
    }

    private func layoutTextLabel() {
        textLabel.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(horizontalPadding)
            make.trailing.equalToSuperview().offset(-horizontalPadding)
            make.top.equalToSuperview().offset(verticalPadding)
            make.bottom.equalToSuperview().offset(-verticalPadding)
        }
    }

    private func configUI() {

        // Background view
        backgroundView.backgroundColor = .black
        backgroundView.layer.cornerRadius = 3
        backgroundView.layer.masksToBounds = true
        self.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Label
        self.addSubview(textLabel)
        textLabel.text = text
        layoutTextLabel()

    }

}