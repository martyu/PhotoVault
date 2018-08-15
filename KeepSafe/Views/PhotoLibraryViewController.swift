//
//  PhotoLibraryViewController.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/12/18.
//  Copyright © 2018 marty. All rights reserved.
//

import Foundation
import UIKit
import PureLayout
import Alamofire
import Differ

class PhotoLibraryViewController: UIViewController {
	private var fullscreen = false

	var imageURLs = [URL]() {
		didSet {
			imageCollectionView.animateItemChanges(oldData: oldValue, newData: imageURLs)
		}
	}
	let cellID = "cellID"
	let itemsPerRow = 3
	
	private func imageURLListCompletionHandler(newURLs: [URL]?, error: Error?) {
		guard
			error == nil,
			let newURLs = newURLs
		else {
			print(error ?? "")
			return
		}
		
		imageURLs += newURLs
	}
	
	private lazy var imageCollectionView: UICollectionView = {
		let imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: gridLayout)
		imageCollectionView.dataSource = self
		imageCollectionView.delegate = self
		imageCollectionView.prefetchDataSource = self
		imageCollectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: cellID)
		imageCollectionView.backgroundColor = .white
		imageCollectionView.contentInsetAdjustmentBehavior = .never
		return imageCollectionView
	}()
	
	override func viewDidLoad() {
		view.addSubview(imageCollectionView)
		imageCollectionView.autoPinEdgesToSuperviewEdges()
		
		sharedImageURLListManager.fetchNextPage(completion: imageURLListCompletionHandler)
	}
}

extension PhotoLibraryViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	var fullScreenLayout: UICollectionViewFlowLayout {
		let fullScreenLayout = UICollectionViewFlowLayout()
		fullScreenLayout.minimumInteritemSpacing = 0.0
		fullScreenLayout.minimumLineSpacing = 0.0
		fullScreenLayout.scrollDirection = .horizontal
		return fullScreenLayout
	}

	var gridLayout: UICollectionViewFlowLayout {
		let gridLayout = UICollectionViewFlowLayout()
		gridLayout.minimumInteritemSpacing = 0.0
		gridLayout.minimumLineSpacing = 0.0
		gridLayout.scrollDirection = .vertical
		return gridLayout
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
		
		if fullscreen {
			let width = collectionView.bounds.width
			let height = collectionView.bounds.height
			return CGSize(width: width, height: height)
		}
		
		let edgeLength = (
			collectionView.frame.size.width -
				collectionView.contentInset.left -
				collectionView.contentInset.right -
				(collectionViewLayout.minimumInteritemSpacing * CGFloat(itemsPerRow))
			) / CGFloat(itemsPerRow)
		
		let size = CGSize(width: edgeLength, height: edgeLength)
		return size
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imageURLs.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
		
		if let photoCell = collectionViewCell as? ImageCollectionCell {
			photoCell.configure(with: imageURLs[indexPath.row])
		}
		
		let threshHold = 10
		if indexPath.row == imageURLs.count - threshHold ||
			imageURLs.count < threshHold {
			sharedImageURLListManager.fetchNextPage(completion: imageURLListCompletionHandler)
		}
		
		return collectionViewCell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		fullscreen = !fullscreen
		configure(collectionView: collectionView, layout: fullscreen ? fullScreenLayout : gridLayout)
		collectionView.scrollToItem(at: indexPath, at: fullscreen ? .centeredHorizontally : .centeredVertically, animated: false)
	}
	
	private func configure(collectionView: UICollectionView, layout: UICollectionViewFlowLayout) {
		if fullscreen {
			collectionView.contentInset = .zero
			collectionView.isPagingEnabled = true
		} else {
			collectionView.isPagingEnabled = false
		}
		
		collectionView.setCollectionViewLayout(layout, animated: false) { _ in
			collectionView.reloadData()
		}
	}
}

extension PhotoLibraryViewController: UICollectionViewDataSourcePrefetching {
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		let urlsToFetch = indexPaths.map { imageURLs[$0.row] }
		sharedImageManager.prefetchImages(for: urlsToFetch)
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		let urlsToCancel = indexPaths.map { imageURLs[$0.row] }
		sharedImageManager.cancelPrefetchingImages(for: urlsToCancel)
	}
}







