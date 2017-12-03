//
// Created by Almas Adilbek on 12/1/17.
// Copyright (c) 2017 Good App. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import CHIPageControl
import GrowingTextView
import DynamicColor
import RxSwift
import RxCocoa

protocol DesignPostViewDelegate : class {
    func designPostViewAddPhotoTapped()
}

final class DesignPostView : UIView {

    let viewModel = DesignPostViewViewModel()
    private let bag = DisposeBag()

    weak var delegate:DesignPostViewDelegate!

    private let containerView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    private let cv:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.zero

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.register(PostPhotoCollectionCell.self, forCellWithReuseIdentifier: "photoCollectionCell")

        return view
    }()

    private let faderView:UIImageView = {
        return UIImageView(image: UIImage(named: "PostFader"))
    }()

    private let addFirstPhotoButton:IconTitleButton = {
        let button = IconTitleButton(iconName: "icon-addphoto-plus", title: "Добавить фото".uppercased())
        button.control.addTarget(self, action: #selector(tapAddPhoto), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private let addNextPhotoButton:UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(tapAddPhoto), for: .touchUpInside)
        button.setImage(UIImage(named: "add-photo-button"), for: .normal)
        button.showsTouchWhenHighlighted = true
        button.isHidden = true
        return button
    }()

    private var deletePhotoButton:UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)
        button.setImage(UIImage(named: "delete-photo-button"), for: .normal)
        button.showsTouchWhenHighlighted = true
        button.isHidden = true
        return button
    }()

    fileprivate let titleTextView:GrowingTextView = {
        let field = GrowingTextView()
        field.backgroundColor = .clear
        field.font = .systemFont(ofSize: 20)
        field.textColor = .white
        field.autocorrectionType = .no
        field.keyboardAppearance = .dark
        field.showsHorizontalScrollIndicator = false
        field.showsVerticalScrollIndicator = false
        field.placeHolder = "Введите заголовок"
        field.trimWhiteSpaceWhenEndEditing = false
        field.minHeight = 40
        return field
    }()

    fileprivate let priceTextView:GrowingTextView = {
        let field = GrowingTextView()
        field.backgroundColor = .clear
        field.font = .boldSystemFont(ofSize: 22)
        field.textColor = .white
        field.autocorrectionType = .no
        field.keyboardAppearance = .dark
        field.showsHorizontalScrollIndicator = false
        field.showsVerticalScrollIndicator = false
        field.placeHolder = "0 ₸"
        field.trimWhiteSpaceWhenEndEditing = false
        field.minHeight = 44
        field.maxLength = 15
        field.keyboardType = .numberPad
        return field
    }()

    fileprivate var pageControl:CHIPageControlChimayo? = nil
    private let badgesContainer = UIView()
    private var titleLengthIndicator:BadgeView?

    // Constraints
    fileprivate var titleTextViewHeightConstraint:ConstraintMakerEditable!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }

    init() {
        super.init(frame:.zero)
        initView()
    }

    private func initView() {
        configUI()
        configEvents()
    }

    private func configEvents() {

        // Title & Price
        _ = titleTextView.rx.text.map{$0!}.bind(to: viewModel.postTitle)
        _ = priceTextView.rx.text.map{$0!}.bind(to: viewModel.price)

        // Post title change
        viewModel.postTitle.asObservable().skip(1).subscribe(onNext: { [weak self] (title:String) in
            guard let _self = self else { return }
            _self.titleLengthIndicator?.text = _self.viewModel.titleLengthIndicatorText
            _self.titleLengthIndicator?.backgroundView.backgroundColor = title.count < _self.viewModel.postTitleMaxLength ? .black : .red
        }).addDisposableTo(bag)

        // If user haven't added any photo yet, then
        // hide addFirstPhotoButton & show addNextPhotoButton if title number of lines > 3
        viewModel.postTitle.asObservable().filter{ $0.count >= 0 && !self.viewModel.hasAtLeastOnePhoto.value }.subscribe(onNext: { [weak self] (title:String) in
            let lines3 = title.components(separatedBy: "\n").count > 1
            self?.addFirstPhotoButton.isHidden = lines3
            self?.addNextPhotoButton.isHidden = !lines3
        }).addDisposableTo(bag)

        // Price value change
        viewModel.price.asObservable().distinctUntilChanged().subscribe(onNext: { [weak self] (price:String) in

            guard let _self = self else { return }

            if price == "" {
                self?.priceTextView.text = ""
            } else {
                // Sanitize the price value
                var newPrice = price.replacingOccurrences(of: " ", with: "")
                        .replacingOccurrences(of: _self.viewModel.currencySymbol, with: "")
                        .trimmingCharacters(in: .whitespaces)

                // Format as thousands separator.
                // This approach also prevents entering the invalid number like "00 ₸", which is automatically converted to "0 ₸"
                guard let intPrice = Int(newPrice) else {
                    self?.priceTextView.text = ""
                    return
                }
                newPrice = intPrice.formattedWithSeparator

                self?.priceTextView.text = "\(newPrice) \(_self.viewModel.currencySymbol)"

                // Calculate the cursor position, two positions back from the end before the " ₸".
                self?.priceFieldPositionCursor()
            }

        }).addDisposableTo(bag)

        // Badges
        viewModel.badgeItems.asObservable().subscribe(onNext: { [weak self] (badges:[BadgeItem]) in
            self?.createBadges(badges)
        }).addDisposableTo(bag)

        // Title length indicator
        viewModel.isTitleEditing.asObservable().skip(1).subscribe(onNext: { [weak self] (editing:Bool) in
            if editing {
                guard let _self = self else { return }
                self?.titleLengthIndicator = BadgeView(text: _self.viewModel.titleLengthIndicatorText)
                self?.titleLengthIndicator?.horizontalPadding = 4
                _self.containerView.addSubview(_self.titleLengthIndicator!)
                self?.titleLengthIndicator?.snp.makeConstraints { make in
                    make.leading.top.equalToSuperview().offset(_self.viewModel.postPadding)
                }
            } else {
                self?.titleLengthIndicator?.removeFromSuperview()
            }
        }).addDisposableTo(bag)

        // Photos

        // Signal triggered only if first photo added or viewModel.photos becomes empty.
        viewModel.hasAtLeastOnePhoto.asObservable().distinctUntilChanged().subscribe(onNext: { [weak self] (hasPhoto:Bool) in

            print("hasAtLeastOnePhoto: \(hasPhoto)")
            guard let _self = self else { return }

            // Do not show the slider fader if no photo yet.
            self?.faderView.isHidden = !hasPhoto

            // Text views placeholder color
            var textViewColor = UIColor.white
            var placeholderColor = UIColor.white
            if !hasPhoto {
                textViewColor = .appGray
                placeholderColor = UIColor(hexString: "D0D7E2")
            }
            self?.titleTextView.textColor = textViewColor
            self?.priceTextView.textColor = textViewColor
            self?.titleTextView.placeHolderColor = placeholderColor
            self?.priceTextView.placeHolderColor = placeholderColor

            // Add photo buttons
            self?.addFirstPhotoButton.isHidden = hasPhoto
            self?.addNextPhotoButton.isHidden = !hasPhoto
            self?.deletePhotoButton.isHidden = !hasPhoto

        }).addDisposableTo(bag)

        // New photo appended or existing one removed.
        viewModel.photos.asObservable().subscribe(onNext: { [weak self] (photos:[UIImage]) in

            self?.cv.reloadData()

            // Page control
            if photos.count > 1 {
                self?.createPageControl()
            } else {
                self?.pageControl?.removeFromSuperview()
            }

            self?.viewModel.hasAtLeastOnePhoto.value = photos.count > 0

            // Set number of pages of page control.
            self?.pageControl?.numberOfPages = photos.count

        }).addDisposableTo(bag)

        // Preview
        // Note: In DesignPostController `previewSwitch.switchControl.rx.isOn.bind(to:postView.viewModel.isPreview)`
        // also triggers the isPreview signal.
        viewModel.isPreview.asObservable().distinctUntilChanged().skip(1).subscribe(onNext: { [weak self] (isPreview:Bool) in
            // Hide / Display controls
            self?.pageControl?.isHidden = isPreview
            self?.addNextPhotoButton.isHidden = isPreview
            self?.deletePhotoButton.isHidden = isPreview

            // Enable / disable text view's user interaction
            self?.titleTextView.isUserInteractionEnabled = !isPreview
            self?.priceTextView.isUserInteractionEnabled = !isPreview
        }).addDisposableTo(bag)
    }

    fileprivate func priceFieldPositionCursor() {
        //
        var position: Int = priceTextView.text.count - 2
        if position >= 0 {
            if position == 0 {
                position = 1
            }
            if let newPosition = priceTextView.position(from: priceTextView.beginningOfDocument, offset: position) {
                priceTextView.selectedTextRange = priceTextView.textRange(from: newPosition, to: newPosition)
            }
        }
    }

    // MARK: Actions

    @objc private func tapAddPhoto() {
       self.delegate.designPostViewAddPhotoTapped()
    }

    @objc private func deletePhoto() {
        viewModel.deleteCurrentPhoto(at: getCurrentPhotoIndex())
    }

    // MARK: UI

    private func createBadges(_ badges:[BadgeItem]) {

        // Clear previous badges
        for subview in badgesContainer.subviews {
            subview.removeFromSuperview()
        }

        var prevBadge:BadgeView? = nil
        for item in badges {
            let badgeView = BadgeView(text:item.title.uppercased())
            badgeView.backgroundView.backgroundColor = item.backgroundColor
            badgeView.textColor = item.titleColor
            badgesContainer.addSubview(badgeView)

            if prevBadge != nil {
                // Next badge
                badgeView.snp.makeConstraints { make in
                    make.leading.equalTo(prevBadge!.snp.trailing).offset(7)
                }
            } else {
                // First badge
                badgeView.snp.makeConstraints { make in
                    make.leading.equalToSuperview()
                }
            }

            badgeView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }

            prevBadge = badgeView
        }
    }

    private func createPageControl() {
        if pageControl != nil { return }

        pageControl = CHIPageControlChimayo()
        pageControl?.tintColor = .white
        pageControl?.currentPageTintColor = .white
        pageControl?.radius = 3
        containerView.addSubview(pageControl!)
        pageControl?.snp.makeConstraints { make in
            make.centerY.equalTo(addNextPhotoButton)
            make.centerX.equalToSuperview()
        }
    }

    private func configUI() {

        // Container view
        self.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Collection View
        containerView.addSubview(cv)
        cv.delegate = self
        cv.dataSource = self
        cv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Set collection view layout item size.
        let width = ScreenSize.SCREEN_WIDTH - 2 * viewModel.margin
        (cv.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: width, height: width)

        // Fader
        containerView.addSubview(faderView)
        faderView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // Input fields
        let fieldsMargin = 15

        containerView.addSubview(titleTextView)
        containerView.addSubview(priceTextView)

        priceTextView.delegate = self
        priceTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(fieldsMargin)
            make.bottom.equalToSuperview().offset(-7)
            make.trailing.equalToSuperview().offset(-fieldsMargin)
            make.height.equalTo(44)
        }

        titleTextView.delegate = self
        titleTextView.maxLength = viewModel.postTitleMaxLength
        titleTextView.snp.makeConstraints { make in
            make.leading.equalTo(priceTextView)
            make.bottom.equalTo(priceTextView.snp.top).offset(5)
            make.trailing.equalToSuperview().offset(-20)
            titleTextViewHeightConstraint = make.height.equalTo(40)
        }

        // Controls ---

        containerView.insertSubview(addFirstPhotoButton, belowSubview: titleTextView)
        addFirstPhotoButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        containerView.addSubview(addNextPhotoButton)
        addNextPhotoButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.viewModel.postPadding)
            make.trailing.equalToSuperview().offset(-self.viewModel.postPadding)
        }

        containerView.addSubview(deletePhotoButton)
        deletePhotoButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.viewModel.postPadding)
            make.trailing.equalTo(self.addNextPhotoButton.snp.leading).offset(-self.viewModel.postPadding)
        }

        // Badges container
        containerView.addSubview(badgesContainer)
        badgesContainer.isUserInteractionEnabled = false
        badgesContainer.snp.makeConstraints { make in
            make.leading.equalTo(titleTextView).offset(5)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(titleTextView.snp.top).offset(-1)
            make.height.equalTo(25)
        }
    }

    // MARK: Helper

    private func getCurrentPhotoIndex() -> Int {
        let offset = cv.contentOffset.x

        if offset == 0 {
            return 0
        }

        return Int(floor(offset / cv.bounds.width))
    }

}

// MARK: UITextView

extension DesignPostView : GrowingTextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        // Price text view
        if textView == priceTextView {
            delay(0.05) {
                self.priceFieldPositionCursor()
            }
        } else if textView == titleTextView {
            viewModel.isTitleEditing.value = true
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // Price text view
        if textView == titleTextView {
            viewModel.isTitleEditing.value = false
        }
    }

    // MARK: GrowingTextView

    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        // Update title text view height
        titleTextViewHeightConstraint.constraint.update(offset: height)
    }

}

// MARK: CollectionView

extension DesignPostView : UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    // MARK: UIScrollView

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let control = pageControl {
            let total = scrollView.contentSize.width - scrollView.bounds.width
            let offset = scrollView.contentOffset.x
            control.progress = Double(offset / total) * Double(control.numberOfPages - 1)
        }
    }

    // MARK: CollectionView

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionCell", for: indexPath) as! PostPhotoCollectionCell
        cell.setPhoto(viewModel.photos.value[indexPath.row])
        return cell
    }

}
