//
//  Example.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import Combine

struct Photos: Codable {
    var samples = [String]()
}

//  https://stackoverflow.com/questions/59505048/combine-swiftui-remote-fetch-data-objectbinding-doesnt-update-view

public class PhotosViewModel: ObservableObject {

    @Published var photos = Photos()

    // var cancellable: AnyCancellable? -> change to Set<AnyCancellable>
    private var cancellables = Set<AnyCancellable>()
    private let urlSession: URLSession

    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
}

extension PhotosViewModel {

    func populatePhotoCollection(named nameOfPhotoCollection: String) {
        fetchPhotoCollection(named: nameOfPhotoCollection)
            .assign(to: \.photos, on: self)
            .store(in: &cancellables)
    }

    func fetchPhotoCollection(named nameOfPhotoCollection: String) -> AnyPublisher<Photos, Never> {
        func emptyPublisher(completeImmediately: Bool = true) -> AnyPublisher<Photos, Never> {
            Empty<Photos, Never>(completeImmediately: completeImmediately).eraseToAnyPublisher()
        }

        // This really ought to be moved to some APIClient
        guard let url = URL(string: "https://api.unsplash.com/users/…/collections?client_id=…") else {
            return emptyPublisher()
        }

        return urlSession.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Photos.self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<Photos, Never> in
                print("☣️ error decoding: \(error)")
                return emptyPublisher()
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

//  DataFetcher
public final class DataFetcher {

    private let dataFromRequest:  (URLRequest) -> AnyPublisher<Data, HTTPError.NetworkingError>
    public init(dataFromRequest: @escaping  (URLRequest) -> AnyPublisher<Data, HTTPError.NetworkingError>) {
        self.dataFromRequest = dataFromRequest
    }
}

public extension DataFetcher {
    func fetchData(request: URLRequest) -> AnyPublisher<Data, HTTPError.NetworkingError> {
        dataFromRequest(request)
    }
}

// MARK: Convenience init
public extension DataFetcher {

    static func urlResponse(
        errorMessageFromDataMapper: ErrorMessageFromDataMapper,
        headerInterceptor: (([AnyHashable: Any]) -> Void)?,
        badStatusCodeInterceptor: ((UInt) -> Void)?,
        _ dataAndUrlResponsePublisher: @escaping (URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
    ) -> DataFetcher {

        DataFetcher { request in
            dataAndUrlResponsePublisher(request)
                .mapError { HTTPError.NetworkingError.urlError($0) }
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw HTTPError.NetworkingError.invalidServerResponse(response)
                    }

                    headerInterceptor?(httpResponse.allHeaderFields)

                    guard case 200...299 = httpResponse.statusCode else {

                        badStatusCodeInterceptor?(UInt(httpResponse.statusCode))

                        let dataAsErrorMessage = errorMessageFromDataMapper.errorMessage(from: data) ?? "Failed to decode error from data"
                        print("⚠️ bad status code, error message: <\(dataAsErrorMessage)>, httpResponse: `\(httpResponse.debugDescription)`")
                        throw HTTPError.NetworkingError.invalidServerStatusCode(httpResponse.statusCode)
                    }
                    return data
            }
            .mapError { castOrKill(instance: $0, toType: HTTPError.NetworkingError.self) }
            .eraseToAnyPublisher()

        }
    }

    // MARK: From URLSession
    static func usingURLSession(
        errorMessageFromDataMapper: ErrorMessageFromDataMapper,
        headerInterceptor: (([AnyHashable: Any]) -> Void)?,
        badStatusCodeInterceptor: ((UInt) -> Void)?,
        urlSession: URLSession = .shared
    ) -> DataFetcher {

        .urlResponse(
            errorMessageFromDataMapper: errorMessageFromDataMapper,
            headerInterceptor: headerInterceptor,
            badStatusCodeInterceptor: badStatusCodeInterceptor
        ) { urlSession.dataTaskPublisher(for: $0).eraseToAnyPublisher() }
    }
}

// MARK: HTTPClient
public final class DefaultHTTPClient {
    public typealias Error = HTTPError

    public let baseUrl: URL

    private let jsonDecoder: JSONDecoder
    private let dataFetcher: DataFetcher

    private var cancellables = Set<AnyCancellable>()

    public init(
        baseURL: URL,
        dataFetcher: DataFetcher,
        jsonDecoder: JSONDecoder = .init()
    ) {
        self.baseUrl = baseURL
        self.dataFetcher = dataFetcher
        self.jsonDecoder = jsonDecoder
    }
}

public extension DefaultHTTPClient {

    func perform(absoluteUrlRequest urlRequest: URLRequest) -> AnyPublisher<Data, HTTPError.NetworkingError> {
        return Combine.Deferred {
            return Future<Data, HTTPError.NetworkingError> { [weak self] promise in

                guard let self = self else {
                    promise(.failure(.clientWasDeinitialized))
                    return
                }

                self.dataFetcher.fetchData(request: urlRequest)

                    .sink(
                        receiveCompletion: { completion in
                            guard case .failure(let error) = completion else { return }
                            promise(.failure(error))
                    },
                        receiveValue: { data in
                            promise(.success(data))
                    }
                ).store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }

    func performRequest(pathRelativeToBase path: String) -> AnyPublisher<Data, HTTPError.NetworkingError> {
        let url = URL(string: path, relativeTo: baseUrl)!
        let urlRequest = URLRequest(url: url)
        return perform(absoluteUrlRequest: urlRequest)
    }

    func fetch<D>(urlRequest: URLRequest, decodeAs: D.Type) -> AnyPublisher<D, HTTPError> where D: Decodable {
        return perform(absoluteUrlRequest: urlRequest)
            .mapError { print("☢️ got networking error: \($0)"); return castOrKill(instance: $0, toType: HTTPError.NetworkingError.self) }
            .mapError { HTTPError.networkingError($0) }
            .decode(type: D.self, decoder: self.jsonDecoder)
            .mapError { print("☢️ 🚨 got decoding error: \($0)"); return castOrKill(instance: $0, toType: DecodingError.self) }
            .mapError { Error.serializationError(.decodingError($0)) }
            .eraseToAnyPublisher()
    }

}

//  Helpers
public protocol ErrorMessageFromDataMapper {
    func errorMessage(from data: Data) -> String?
}


public enum HTTPError: Swift.Error {
    case failedToCreateRequest(String)
    case networkingError(NetworkingError)
    case serializationError(SerializationError)
}

public extension HTTPError {
    enum NetworkingError: Swift.Error {
        case urlError(URLError)
        case invalidServerResponse(URLResponse)
        case invalidServerStatusCode(Int)
        case clientWasDeinitialized
    }

    enum SerializationError: Swift.Error {
        case decodingError(DecodingError)
        case inputDataNilOrZeroLength
        case stringSerializationFailed(encoding: String.Encoding)
    }
}

internal func castOrKill<T>(
    instance anyInstance: Any,
    toType expectedType: T.Type,
    _ file: String = #file,
    _ line: Int = #line
) -> T {

    guard let instance = anyInstance as? T else {
        let incorrectTypeString = String(describing: Mirror(reflecting: anyInstance).subjectType)
        fatalError("Expected variable '\(anyInstance)' (type: '\(incorrectTypeString)') to be of type `\(expectedType)`, file: \(file), line:\(line)")
    }
    return instance
}
