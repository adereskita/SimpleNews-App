//
//  Endpoint.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var header: [String: String]? { get }
    var body: [String: String]? { get }
    var queryItems: [String : String] { get }
}

extension Endpoint {
    var scheme: String {
        return "https"
    }

    var host: String {
        return Constant.baseURL.rawValue
    }
}
