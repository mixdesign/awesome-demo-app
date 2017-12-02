//
// Created by Almas Adilbek on 12/1/17.
// Copyright (c) 2017 Good App. All rights reserved.
//

import Foundation
import CoreGraphics
import RxSwift

final class DesignPostViewViewModel {

    private let bag = DisposeBag()

    let margin:CGFloat = 15
    let titleFieldMaxLength = 70

    var isUrgent = Variable<Bool>(false)
    var isGiveFree = Variable<Bool>(false)
    var badgeItems = Variable<[BadgeItem]>([])

    init() {

        isUrgent.asObservable().skip(1).distinctUntilChanged().subscribe(onNext: { [weak self] (isOn:Bool) in
            if isOn {
                self?.badgeItems.value.append(BadgeItem(title: BadgeType.urgent.rawValue.uppercased(), titleColor: .flatBlack, backgroundColor: UIColor(hexString: "F7C644")))
            } else {
                self?.removeBadge(with: .urgent)
            }
        }).addDisposableTo(bag)

        isGiveFree.asObservable().skip(1).distinctUntilChanged().subscribe(onNext: { [weak self] (isOn:Bool) in
            if isOn {
                self?.badgeItems.value.append(BadgeItem(title: BadgeType.giveFree.rawValue.uppercased(), titleColor: .white, backgroundColor: UIColor(hexString: "11A574")))
            } else {
                self?.removeBadge(with: .giveFree)
            }
        }).addDisposableTo(bag)

    }

    // MARK: Helper

    private func removeBadge(with type: BadgeType) {
        for (index, item) in badgeItems.value.enumerated() {
            if item.title.lowercased() == type.rawValue.lowercased() {
                badgeItems.value.remove(at: index)
                break
            }
        }
    }
}

private enum BadgeType:String {
    case urgent = "Срочно"
    case giveFree = "Отдам даром"
}

struct BadgeItem {
    let title:String
    let titleColor:UIColor
    let backgroundColor:UIColor

    init(title:String, titleColor:UIColor, backgroundColor:UIColor) {
        self.title = title
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
    }
}