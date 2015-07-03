//
//  PrototypeListCollectionViewController.swift
//  Protomath
//
//  Created by Jason Brennan on 2015-06-22.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import UIKit


/** Shows a list of Prototypes loaded from the application's bundle and lets you tap to play. */
class PrototypeListCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	
	private let prototypeProvider = PrototypeProvider()
	private let layout: UICollectionViewFlowLayout = {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		return layout
	}()

	init() {
		super.init(collectionViewLayout: layout)
	}

	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		collectionView!.registerClass(PrototypePreviewCell.self, forCellWithReuseIdentifier: PrototypePreviewCell.reuseIdentifier)
		collectionView!.backgroundColor = UIColor.whiteColor()
		navigationItem.title = "Prototypes"
	}

	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return prototypeProvider.prototypes.count
	}

	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}

	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PrototypePreviewCell.reuseIdentifier, forIndexPath: indexPath) as! PrototypePreviewCell
		cell.prototype = self.prototypeProvider.prototypes[indexPath.item]
		return cell
	}

	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let prototype = self.prototypeProvider.prototypes[indexPath.item]

		if prototype.readmeURL != nil {
			navigationController?.pushViewController(ReadmeViewController(prototype: prototype), animated: true)
		} else {
			navigationController?.pushViewController(PlayerViewController(path: prototype.mainFileURL), animated: true)
		}
	}

	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		layout.invalidateLayout()
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let width = collectionView.bounds.size.width / round(collectionView.bounds.size.width / PrototypePreviewCell.desiredSize.width)
		let height = width * PrototypePreviewCell.desiredSize.height / PrototypePreviewCell.desiredSize.width
		return CGSize(width: floor(width), height: floor(height))
	}

}


private class PrototypePreviewCell: UICollectionViewCell {
	static let desiredSize = CGSize(width: 256, height: 192)
	static let labelHeight: CGFloat = 50
	static let labelHorizontalPadding: CGFloat = 15

	var prototype: Prototype? {
		didSet {
			imageView.backgroundColor = UIColor(hue: CGFloat(rand()) / CGFloat(Int32.max), saturation: 1, brightness: 1, alpha: 1)
			if let previewImageURL = prototype?.previewImageURL {
				precondition(previewImageURL.fileURL)
				if previewImageURL.pathExtension! == "gif" {
					// do you believe in async after love
					imageView.animatedImage = FLAnimatedImage(animatedGIFData: NSData(contentsOfURL: previewImageURL))
				} else {
					imageView.image = UIImage(contentsOfFile: previewImageURL.path!)
				}
			} else {
				imageView.image = nil
				imageView.animatedImage = nil
			}
			label.text = prototype?.name
			setNeedsLayout()
		}
	}

	let imageView = FLAnimatedImageView()
	let label = UILabel()
	let labelBar: UIVisualEffectView
	let labelVibrancyContainer: UIVisualEffectView

	override init(frame: CGRect) {
		let blurEffect = UIBlurEffect(style: .ExtraLight)
		labelBar = UIVisualEffectView(effect: blurEffect)
		labelVibrancyContainer = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))

		super.init(frame: frame)

		contentView.addSubview(imageView)

		contentView.addSubview(labelBar)

		labelBar.contentView.addSubview(labelVibrancyContainer)
		labelVibrancyContainer.contentView.addSubview(label)

	}

	private override func layoutSubviews() {
		super.layoutSubviews()

		imageView.frame = contentView.bounds
		labelBar.frame = CGRect(
			x: 0,
			y: contentView.bounds.size.height - PrototypePreviewCell.labelHeight,
			width: contentView.bounds.size.width,
			height: PrototypePreviewCell.labelHeight
		)
		labelVibrancyContainer.frame = labelBar.bounds
		label.frame = CGRectInset(labelVibrancyContainer.bounds, PrototypePreviewCell.labelHorizontalPadding, 0)
	}

	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}
}

extension UICollectionViewCell {
	/** Provides a default reuse identifier for cells. */
	class var reuseIdentifier: String { return NSStringFromClass(self.self) }
}

