//
//  ImageCell.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/12/18.
//  Copyright © 2018 marty. All rights reserved.
//

import Foundation
import UIKit
import PureLayout
import Alamofire
import AlamofireImage

class ImageCollectionCell: UICollectionViewCell {
	let imageView = UIImageView()
	let placeholderView: UIActivityIndicatorView = {
		let placeholderView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		placeholderView.backgroundColor = .white
		return placeholderView
	}()
	var urlToLoad: URL?
	let imageManager = sharedImageManager
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.addSubview(imageView)
		imageView.autoPinEdgesToSuperviewEdges()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
	}
	
	func configure(with url: URL) {
		urlToLoad = url
		imageManager.fetchImage(for: url) { [weak self] image, error in
			guard let image = image else { return }
			DispatchQueue.global(qos: .userInitiated).async {
				let decodedImage = self?.decodedImage(image)
				DispatchQueue.main.async {
					if self?.urlToLoad == url {
						self?.showPlaceholderView(false)
						self?.imageView.layer.contents = decodedImage?.cgImage
					}
				}
			}
		}
	}
	
	private func decodedImage(_ image: Image) -> Image? {
		guard let newImage = image.cgImage else { return nil }
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let context = CGContext(data: nil, width: newImage.width, height: newImage.height, bitsPerComponent: 8, bytesPerRow: newImage.width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
		
		context?.draw(newImage, in: CGRect(x: 0, y: 0, width: newImage.width, height: newImage.height))
		let drawnImage = context?.makeImage()
		
		if let drawnImage = drawnImage {
			return Image(cgImage: drawnImage)
		}
		return nil
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		showPlaceholderView(true)
	}
	
	private func showPlaceholderView(_ show: Bool) {
		if show {
			contentView.addSubview(placeholderView)
			placeholderView.autoPinEdgesToSuperviewEdges()
			placeholderView.startAnimating()
		} else {
			placeholderView.removeFromSuperview()
			placeholderView.stopAnimating()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

