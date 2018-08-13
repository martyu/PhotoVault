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
	var loadingURL: URL?
	let placeholderView: UIActivityIndicatorView = {
		let placeholderView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		placeholderView.backgroundColor = .white
		return placeholderView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.addSubview(imageView)
		imageView.autoPinEdgesToSuperviewEdges()
		imageView.contentMode = .scaleAspectFit
	}
	
	func configure(with url: URL) {
		loadingURL = url
		imageView.af_setImage(withURL: url)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.af_cancelImageRequest()
		imageView.image = nil

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

