//
//  ImageURLListManager.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/12/18.
//  Copyright © 2018 marty. All rights reserved.
//

import Foundation
import Alamofire

protocol ImageURLListManagerDelegate {
	func imageURLListUpdated(_: ImageURLListManager)
}

class ImageURLListManager {
	private var imageURLs = [URL]()
	private var lastFetchedPage = 0
	private var delegate: ImageURLListManagerDelegate
	var count: Int { return imageURLs.count }
	
	init(seed: Int, delegate: ImageURLListManagerDelegate) {
		self.delegate = delegate
		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let strongSelf = self else { return }
			func seeder() {
				if strongSelf.imageURLs.count < seed {
					strongSelf.fetchNextPage() { error in
						seeder()
					}
				} else {
					delegate.imageURLListUpdated(strongSelf)
				}
			}
			
			seeder()
		}
	}
	
	private func apiURL(page: Int) -> URL? {
		return URL(string: "https://lit-earth-91645.herokuapp.com/images/\(page)")
	}
	
	func urlForIndex(_ index: Int, completion: @escaping (URL, Error?) -> ()) {
		if index < imageURLs.count {
			completion(imageURLs[index], nil)
		} else {
			fetchNextPage { [weak self] error in
				self?.urlForIndex(index, completion: completion)
			}
		}
	}
	
	private func fetchNextPage(completion: @escaping (Error?) -> ()) {
		lastFetchedPage += 1
		if let pageAPIURL = apiURL(page: lastFetchedPage) {
			Alamofire.request(pageAPIURL).responseJSON { [weak self] json in
				if let data = json.data {
					do {
						guard let strongSelf = self else { return }
						strongSelf.lastFetchedPage += 1
						let imageURLs = try JSONDecoder().decode([String].self, from: data)
						strongSelf.imageURLs += imageURLs.compactMap { URL(string: $0) }
						strongSelf.delegate.imageURLListUpdated(strongSelf)
						completion(nil)
					} catch {
						completion(error)
					}
				}
			}
		}
	}
}
