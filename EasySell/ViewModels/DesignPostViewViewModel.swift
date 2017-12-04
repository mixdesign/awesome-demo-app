//
// Created by Almas Adilbek on 12/1/17.
// Copyright (c) 2017 Good App. All rights reserved.
//

import Foundation
import CoreGraphics
import RxSwift

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

final class DesignPostViewViewModel {

    private let bag = DisposeBag()

    let margin:CGFloat = 15
    let postPadding:CGFloat = 11
    let postTitleMaxLength = 70
    let currencySymbol = "₸"

    var isPreview = Variable<Bool>(false)
    var isTitleEditing = Variable<Bool>(false)
    var isUrgent = Variable<Bool>(false)
    var isGiveFree = Variable<Bool>(false)
    var hasAtLeastOnePhoto = Variable<Bool>(false)
    var formValidated = Variable<Bool>(false)

    var postTitle = Variable<String>("")
    var price = Variable<String>("")
    var badgeItems = Variable<[BadgeItem]>([])
    var photos = Variable<[UIImage]>([])

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
        }).addDisposableTo(bag)

        isGiveFree.asObservable().skip(1).distinctUntilChanged().subscribe(onNext: { [weak self] (isOn:Bool) in
            if isOn {
                self?.badgeItems.value.append(BadgeItem(title: BadgeType.giveFree.rawValue.uppercased(), titleColor: .white, backgroundColor: UIColor(hexString: "11A574")))
            } else {
                self?.removeBadge(with: .giveFree)
            }
        }).addDisposableTo(bag)

        // Is photo added
        photos.asObservable().subscribe(onNext: { [weak self] (photos:[UIImage]) in
            self?.hasAtLeastOnePhoto.value = photos.count > 0
            self?.updateFormValidated()
        }).addDisposableTo(bag)

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