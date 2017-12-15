//
// Created by Almas Adilbek on 12/1/17.
// Copyright (c) 2017 GOOD/APP. All rights reserved.
//

import Foundation
import CoreGraphics
import RxSwift

private enum BadgeType:String {
    case urgent = "Urgent"
    case giveFree = "Free"
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

final class DesignPostViewViewModel {

    private let bag = DisposeBag()

    let margin:CGFloat = 15
    let postPadding:CGFloat = 11
    let postTitleMaxLength = 70
    let currencySymbol = "₸"

    let isPreview = Variable<Bool>(false)
    let isTitleEditing = Variable<Bool>(false)
    let isUrgent = Variable<Bool>(false)
    let isGiveFree = Variable<Bool>(false)
    let hasAtLeastOnePhoto = Variable<Bool>(false)
    let formValidated = Variable<Bool>(false)

    let postTitle = Variable<String>("")
    let price = Variable<String>("")
    let badgeItems = Variable<[BadgeItem]>([])
    let photos = Variable<[UIImage]>([])

    var titleLengthIndicatorText:String {
        return "\(postTitleMaxLength - self.postTitle.value.count)"
    }

    init() {

        // Badge controls
        isUrgent.asObservable().skip(1).distinctUntilChanged().subscribe(onNext: { [weak self] (isOn:Bool) in
            if isOn {
                self?.badgeItems.value.append(BadgeItem(title: BadgeType.urgent.rawValue.uppercased(), titleColor: .flatBlack, backgroundColor: UIColor(hexString: "F7C644")))
            } else {
                self?.removeBadge(with: .urgent)
            }
        }).disposed(by:bag)

        isGiveFree.asObservable().skip(1).distinctUntilChanged().subscribe(onNext: { [weak self] (isOn:Bool) in
            if isOn {
                self?.badgeItems.value.append(BadgeItem(title: BadgeType.giveFree.rawValue.uppercased(), titleColor: .white, backgroundColor: UIColor(hexString: "11A574")))
            } else {
                self?.removeBadge(with: .giveFree)
            }
        }).disposed(by:bag)

        // Is photo added
        photos.asObservable().subscribe(onNext: { [weak self] (photos:[UIImage]) in
            self?.hasAtLeastOnePhoto.value = photos.count > 0
            self?.updateFormValidated()
        }).disposed(by:bag)

    }

    // Return pure digits price value
    func intPrice() -> Int {
        if let value = Int(price.value.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: currencySymbol, with: "")) {
            return value
        }
        return 0
    }

    func deleteCurrentPhoto(at index:Int) {
        if photos.value.count == 0 { return }

        photos.value.remove(at: index)
    }

    func updateFormValidated() {
        // Form is validated -> If at least one photo added AND title is not empty
        formValidated.value = hasAtLeastOnePhoto.value && !postTitle.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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