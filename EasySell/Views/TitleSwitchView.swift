//
// Created by Almas Adilbek on 12/1/17.
// Copyright (c) 2017 Good App. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class TitleSwitchView : UIView {

    let titleLabel:UILabel = {
        let label = UILabel.base().font(.boldSystemFont(ofSize: 8)).color(.appGray)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let switchControl:UISwitch = {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTintColor = .appBlueLight
        return view
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configUI()
    }

    init() {
        super.init(frame:.zero)
        configUI()
    }

    func setTitle(_ title:String) {
        titleLabel.text = title
    }

    private func configUI() {

        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(7)
        }

        self.addSubview(switchControl)
        switchControl.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.bottom.equalToSuperview()
        }

        self.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(titleLabel).offset(7)
            make.width.greaterThanOrEqualTo(switchControl)
        }
    }

}