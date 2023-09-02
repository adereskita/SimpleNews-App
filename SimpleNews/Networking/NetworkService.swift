//
//  NetworkService.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import Foundation

//protocol NetworkServiceProtocol {
//    func request<Request: DataRequest>(_ request: Request, completion: @escaping (Result<Request.Response, NetworkError>) -> Void)
//}

//final class NetworkService: NetworkServiceProtocol {
//
//    func request<Request: DataRequest>(_ request: Request, completion: @escaping (Result<Request.Response, NetworkError>) -> Void) {
//
//        guard var urlComponent = URLComponents(string: request.url) else {
//            return completion(.failure(NetworkError.invalidURL))
//        }
//
//        var queryItems: [URLQueryItem] = []
//
//        request.queryItems.forEach {
//            let urlQueryItem = URLQueryItem(name: $0.key, value: $0.value)
//            urlComponent.queryItems?.append(urlQueryItem)
//            queryItems.append(urlQueryItem)
//        }
//
//        urlComponent.queryItems = queryItems
//
//        guard let url = urlComponent.url else {
//            return completion(.failure(NetworkError.invalidURL))
//        }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = request.method.rawValue
//        urlRequest.allHTTPHeaderFields = request.headers
//
//        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
//
//            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
//                return completion(.failure(NetworkError.invalidResponse))
//            }
//
//            guard let data = data else {
//                return completion(.failure(NetworkError.invalidResponse))
//            }
//
//            do {
//                try completion(.success(request.decode(data)))
//            } catch {
//                completion(.failure(NetworkError.decodingFailed))
//            }
//        }
//        .resume()
//    }
//}
