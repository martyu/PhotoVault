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

class PhotoLibraryViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	var imageURLs = [URL]() {
		didSet {
			imageCollectionView.animateItemChanges(oldData: oldValue, newData: imageURLs)
		}
	}
	let cellID = "cellID"
	let imageURLListManager = ImageURLListManager()
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
			imageURLListManager.fetchNextPage(completion: imageURLListCompletionHandler)
		}
		
		return collectionViewCell
	}
	
	private lazy var imageCollectionFlowLayout: UICollectionViewFlowLayout = {
		let imageCollectionFlowLayout = UICollectionViewFlowLayout()
		imageCollectionFlowLayout.minimumInteritemSpacing = 4.0
		return imageCollectionFlowLayout
	}()
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
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
	
	private lazy var imageCollectionView: UICollectionView = {
		let imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: imageCollectionFlowLayout)
		imageCollectionView.dataSource = self
		imageCollectionView.delegate = self
		imageCollectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: cellID)
		imageCollectionView.backgroundColor = .white
		imageCollectionView.contentInset.left = 8.0
		imageCollectionView.contentInset.right = 8.0
		return imageCollectionView
	}()
	
	override func viewDidLoad() {
		view.addSubview(imageCollectionView)
		imageCollectionView.autoPinEdgesToSuperviewEdges()
		
		imageURLListManager.fetchNextPage(completion: imageURLListCompletionHandler)
	}
}
