//
// Created by Almas Adilbek on 12/1/17.
// Copyright (c) 2017 GOOD/APP. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import DynamicColor

final class IconTitleButton : UIView {

    let control = UIControl()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(iconName:String, title:String? = nil) {
        super.init(frame:.zero)

        let iconView = UIImageView(image: UIImage(named: iconName))
        self.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()

            if title == nil {
                make.bottom.equalToSuperview()
            }
        }

        var label:UILabel? = nil
        if let title = title {
            label = UILabel.base().font(.boldSystemFont(ofSize: 10)).color(UIColor(hexString: "CFD7E3")).text(title)
            label?.setLetter(spacing: 1)
            self.addSubview(label!)
            label?.snp.makeConstraints { make in
                make.top.equalTo(iconView.snp.bottom).offset(15)
                make.centerX.bottom.equalToSuperview()
            }
        }

        self.addSubview(control)
        control.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(iconView)

            if let label = label {
                make.width.greaterThanOrEqualTo(label)
            }
        }

    }

}