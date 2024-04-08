//
//  NetworkError.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import Foundation

enum NetworkError: Error {
    case badRequest(_ statusCode: Int)
    case notFound(_ statusCode: Int)
    case error(_ statusCode: Int)
    case server(_ statusCode: Int)
    case decoding
    case invalidImage
    case invalidUrl
    case invalidImageUrl
    case originalImageUrlNotFound
    case other(Error)
    case notConnectedToInternet
    case networkConnectionLost
    case unknown
    
    static func mapError(_ error: Error) -> NetworkError {
        switch error {
        case is Swift.DecodingError:
            return .decoding
        case let error as NetworkError:
            return error
        case URLError.notConnectedToInternet:
            return .notConnectedToInternet
        case URLError.networkConnectionLost:
            return .networkConnectionLost
        default:
            return .other(error)
        }
    }
    
    static func mapErrorByStatusCode(_ statusCode: Int) -> NetworkError {
        switch statusCode {
            case 400:
                return .badRequest(statusCode)
            case 404:
                return .notFound(statusCode)
            case 402, 405...499, 501...599:
                return .error(statusCode)
            case 500:
                return .server(statusCode)
            default:
                return .unknown
        }
    }
    
    static func getMessageForError(_ error: NetworkError) -> String {
        var message = ""
        
        switch error {
        case .badRequest(let statusCode):
            message = Util.localizedString("network.error.message.bad.request", arg: statusCode)
        case .notFound(let statusCode):
            message = Util.localizedString("network.error.message.not.found", arg: statusCode)
        case .error(let statusCode):
            message = Util.localizedString("network.error.message.status.code", arg: statusCode)
        case .server(let statusCode):
            message = Util.localizedString("network.error.message.server", arg: statusCode)
        case .decoding:
            message = Util.localizedString("network.error.message.decoding")
        case .invalidImage:
            message = Util.localizedString("network.error.message.invalid.image")
        case .invalidUrl:
            message = Util.localizedString("network.error.message.invalid.url")
        case .invalidImageUrl:
            message = Util.localizedString("network.error.message.invalid.image.url")
        case .originalImageUrlNotFound:
            message = Util.localizedString("network.error.message.original.image.not.found")
        case .other(let error):
            message = error.localizedDescription
        case .notConnectedToInternet:
            message = Util.localizedString("network.error.message.no.connection")
        case .networkConnectionLost:
            message = Util.localizedString("network.error.message.lost.connection")
        case .unknown:
            message = Util.localizedString("network.error.message.unknown")
        }
        
        Util.log(message)
        
        return message
    }
}


