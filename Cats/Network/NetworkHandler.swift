//
//  NetworkHandler.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import Foundation
import Combine

protocol NetworkHandler {
    func fetchData<Result: Codable>(_ type: Result.Type, urlString: String) -> AnyPublisher<Result, NetworkError>
}
