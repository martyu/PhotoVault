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
	
	private lazy var imageCollectionFlowLayout: UICollectionViewFlowLayout = {
		let imageCollectionFlowLayout = UICollectionViewFlowLayout()
		imageCollectionFlowLayout.minimumInteritemSpacing = 0.0
		imageCollectionFlowLayout.minimumLineSpacing = 0.0
		return imageCollectionFlowLayout
	}()
	
	private lazy var imageCollectionView: UICollectionView = {
		let imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: imageCollectionFlowLayout)
		imageCollectionView.dataSource = self
		imageCollectionView.delegate = self
		imageCollectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: cellID)
		imageCollectionView.backgroundColor = .white
		return imageCollectionView
	}()
	
	override func viewDidLoad() {
		view.addSubview(imageCollectionView)
		imageCollectionView.autoPinEdgesToSuperviewEdges()
		
		sharedImageURLListManager.fetchNextPage(completion: imageURLListCompletionHandler)
	}
}

extension PhotoLibraryViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
		
		if fullscreen {
			let width = collectionView.bounds.width// collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right + collectionViewLayout.minimumLineSpacing
			let height = collectionView.bounds.height// collectionView.frame.size.height - collectionView.contentInset.top - collectionView.contentInset.bottom + collectionViewLayout.minimumLineSpacing
			return CGSize(width: width, height: height)
		}
		
		let edgeLength = (
			collectionView.frame.size.width -
				collectionView.contentInset.left -
				collectionView.contentInset.right -
				(collectionViewLayout.minimumInteritemSpacing * CGFloat(itemsPerRow))
			) / CGFloat(itemsPerRow)
		
		let size = CGSize(width: edgeLength, height: edgeLength)
		if Int(size.width) != 128 {
			print(size)
		}
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
		guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
		fullscreen = !fullscreen
		configure(collectionView: collectionView, layout: flowLayout)
		flowLayout.invalidateLayout()
		collectionView.reloadData()
		collectionView.scrollToItem(at: indexPath, at: fullscreen ? .centeredHorizontally : .centeredVertically, animated: false)
	}
	
	private func configure(collectionView: UICollectionView, layout: UICollectionViewFlowLayout) {
		if fullscreen {
			layout.scrollDirection = .horizontal
			collectionView.contentInset = .zero
			collectionView.isPagingEnabled = true
		} else {
			layout.scrollDirection = .vertical
			collectionView.isPagingEnabled = false
		}
	}
}









