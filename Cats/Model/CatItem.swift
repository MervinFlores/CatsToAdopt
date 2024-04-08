//
//  CatItem.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import Foundation

struct CatItem: Codable {
    let id: String
    let tags: [String]?
    let owner: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case tags
        case owner
        case createdAt
        case updatedAt
    }
}

extension CatItem {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM dd yyyy HH:mm:ss 'GMT'Z (zzzz)"
        return formatter
    }()
    
    func getImageURLString() -> String {
        return "https://cataas.com/cat/\(self.id)"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        owner = try container.decodeIfPresent(String.self, forKey: .owner)
        
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt),
           let createdAtDate = CatItem.dateFormatter.date(from: createdAtString) {
            createdAt = createdAtDate
        } else {
            createdAt = nil
        }
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt),
           let updatedAtDate = CatItem.dateFormatter.date(from: updatedAtString) {
            updatedAt = updatedAtDate
        } else {
            updatedAt = nil
        }
    }
}
