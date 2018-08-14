//
//  ImageURLListManager.swift
//  KeepSafe
//
//  Created by Marty Ulrich on 8/12/18.
//  Copyright © 2018 marty. All rights reserved.
//

import Foundation
import Alamofire

class ImageURLListManager {
	private var lastFetchedPage = 0
	private let requestQueue = OperationQueue()
	private func apiURL(page: Int) -> URL? {
		return URL(string: "https://lit-earth-91645.herokuapp.com/images/\(page)")
	}
	
	func fetchNextPage(completion: @escaping ([URL]?, Error?) -> ()) {
		lastFetchedPage += 1
		if let pageAPIURL = apiURL(page: lastFetchedPage) {
			Alamofire.request(pageAPIURL).responseJSON { [weak self] json in
				if let data = json.data {
					do {
						guard let strongSelf = self else { return }
						strongSelf.lastFetchedPage += 1
						let imageURLs = try JSONDecoder().decode([URL].self, from: data)
						completion(imageURLs, nil)
					} catch {
						completion(nil, error)
					}
				}
			}
		}
	}
}
