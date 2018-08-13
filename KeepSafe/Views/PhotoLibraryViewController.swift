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

class PhotoLibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ImageURLListManagerDelegate {
	func imageURLListUpdated(_: ImageURLListManager) {
		imageCollectionView.reloadData()
	}
	
	let cellID = "cellID"
	lazy var imageURLListManager = ImageURLListManager(seed: 20, delegate: self)
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imageURLListManager.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
		
		if let photoCell = collectionViewCell as? ImageCollectionCell {
			imageURLListManager.urlForIndex(indexPath.row) { url, error in
				photoCell.configure(with: url)
			}
		}
		
		return collectionViewCell
	}
	
	private lazy var imageCollectionFlowLayout: UICollectionViewFlowLayout = {
		let imageCollectionFlowLayout = UICollectionViewFlowLayout()
		imageCollectionFlowLayout.itemSize = CGSize(width: 75, height: 75)
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidLoad() {
		view.addSubview(imageCollectionView)
		imageCollectionView.autoPinEdgesToSuperviewMargins()

	}
}
