//
//  HTTPClient.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import Foundation

protocol HTTPClient {
//    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T, RequestError>
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type, completionHandler: @escaping (Result<T, RequestError>) -> Void)
}

extension HTTPClient {
//    func sendRequest<T: Decodable>(
//        endpoint: Endpoint,
//        responseModel: T.Type
//    ) async -> Result<T, RequestError> {
//        var urlComponents = URLComponents()
//        urlComponents.scheme = endpoint.scheme
//        urlComponents.host = endpoint.host
//        urlComponents.path = endpoint.path
//
//        guard let url = urlComponents.url else {
//            return .failure(.invalidURL)
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = endpoint.method.rawValue
//        request.allHTTPHeaderFields = endpoint.header
//
//        if let body = endpoint.body {
//            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
//        }
//
//        do {
//            if #available(iOS 15.0, *) {
//                let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
//                guard let response = response as? HTTPURLResponse else {
//                    return .failure(.noResponse)
//                }
//                switch response.statusCode {
//                case 200...299:
//                    guard let decodedResponse = try? JSONDecoder().decode(responseModel, from: data) else {
//                        return .failure(.decode)
//                    }
//                    return .success(decodedResponse)
//                case 401:
//                    return .failure(.unauthorized)
//                default:
//                    return .failure(.unexpectedStatusCode)
//                }
//            } else {
//                return .failure(.unexpectedStatusCode)
//            }
//        } catch {
//            return .failure(.unknown)
//        }
//    }
    
    func sendRequest<T: Decodable>(
            endpoint: Endpoint,
            responseModel: T.Type,
            completionHandler: @escaping (Result<T, RequestError>) -> Void
        ) {
            var urlComponents = URLComponents()
            
            var queryItems: [URLQueryItem] = []
            
            endpoint.queryItems.forEach {
                let urlQueryItem = URLQueryItem(name: $0.key, value: $0.value)
                urlComponents.queryItems?.append(urlQueryItem)
                queryItems.append(urlQueryItem)
            }
            
            urlComponents.queryItems = queryItems
            
            urlComponents.scheme = endpoint.scheme
            urlComponents.host = endpoint.host
            urlComponents.path = endpoint.path
            
            guard let url = urlComponents.url else {
                completionHandler(.failure(.invalidURL))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.allHTTPHeaderFields = endpoint.header

            if let body = endpoint.body {
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    completionHandler(.failure(.invalidURL))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completionHandler(.failure(.noResponse))
                    return
                }

                switch httpResponse.statusCode {
                case 200...299:
                    guard let responseData = data else {
                        completionHandler(.failure(.noResponse))
                        return
                    }
                    do {
                        let decodedResponse = try JSONDecoder().decode(responseModel, from: responseData)
                        completionHandler(.success(decodedResponse))
                    } catch let error{
                        print(error)
                        completionHandler(.failure(.decode))
                    }
                case 401:
                    completionHandler(.failure(.unauthorized))
                default:
                    completionHandler(.failure(.unexpectedStatusCode))
                }
            }

            task.resume()
        }
}
