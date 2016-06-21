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

	required init?(coder aDecoder: NSCoder) {
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
	static let labelPadding: CGFloat = 15

	var prototype: Prototype? {
		didSet {
			imageView.backgroundColor = prototype?.colorRepresentation

			if let previewImageURL = prototype?.previewImageURL {
				precondition(previewImageURL.fileURL)
				if previewImageURL.pathExtension! == "gif" {
					// ultra lazy async lol
					dispatch_async(dispatch_get_global_queue(0, 0)) {
						let gifData = NSData(contentsOfURL: previewImageURL)
						let image = FLAnimatedImage(animatedGIFData: gifData)
						dispatch_async(dispatch_get_main_queue()) {
							if self.prototype?.previewImageURL == .Some(previewImageURL) {
								self.imageView.animatedImage = image
							}
						}
					}
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

	let imageView: FLAnimatedImageView = {
		let imageView = FLAnimatedImageView()
		imageView.contentMode = .ScaleAspectFill
		return imageView
	}()

	let label: UILabel = {
		let label = UILabel()
		label.numberOfLines = 2
		return label
	}()

	let labelBar: UIVisualEffectView
	let labelVibrancyContainer: UIVisualEffectView

	override init(frame: CGRect) {
		let blurEffect = UIBlurEffect(style: .Dark)
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

		let labelSizeThatFits = label.sizeThatFits(CGSize(width: contentView.bounds.size.width, height: CGFloat.max))
		let labelHeight = labelSizeThatFits.height + 2 * PrototypePreviewCell.labelPadding

		labelBar.frame = CGRect(
			x: 0,
			y: contentView.bounds.size.height - labelHeight,
			width: contentView.bounds.size.width,
			height: labelHeight
		)
		labelVibrancyContainer.frame = labelBar.bounds
		label.frame = CGRectInset(labelVibrancyContainer.bounds, PrototypePreviewCell.labelPadding, 0)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}
}

extension UICollectionViewCell {
	/** Provides a default reuse identifier for cells. */
	class var reuseIdentifier: String { return NSStringFromClass(self.self) }
}

extension Prototype {
	private var colorRepresentation: UIColor {
		let hue = CGFloat(name.hash % Int(Int16.max)) / CGFloat(Int16.max)
		return UIColor(hue: hue, saturation: 0.8, brightness: 0.96, alpha: 1)
	}
}