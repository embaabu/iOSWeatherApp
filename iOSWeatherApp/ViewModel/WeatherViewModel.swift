//
//  WeatherViewModel.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/9/24.
//

import Foundation
import NetworkPackage
import Combine
import CoreLocation

class WeatherViewModel: ObservableObject{
    let networkManager: Network
    @Published var weatherData = [ResponseBody]()
    @Published var isLoading: Bool = false
    @Published var responseError: Error?
    @Published var searchText = ""
    
    private var cancellable = Set<AnyCancellable>()
    
    init(networkManager: Network) {
        self.networkManager = networkManager

    }
    
    func getWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async{
        let apiKey = ApiKeyManager.valueForKey(key: "WeatherAPIKey")
        print("api key is\(apiKey)")
        let url = "https://api.openweathermap.org/data/2.5/weather"
//        TODO GET THE latitude and the longitude from the location manager
        let queryParams = [
            "lat": "\(latitude)",// change this to the lat
            "lon": "\(longitude)", // change this to the lon
            "units": "metric",
            "appid": "\(apiKey)"
        ]
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            
        }

        
        do{
            guard let fullUrl = buildURL(baseURL: url, queryParams: queryParams) else{
                throw NetworkError.InvalidURLError
            }

            let weatherData = try await self.networkManager.getDataFromUrl(url: fullUrl, modelType: ResponseBody.self)
            print("\(weatherData)")
            DispatchQueue.main.async { [ weak self ] in
                self?.weatherData = [weatherData]
                self?.isLoading = false
            }
            
            
        }catch{
            print(error.localizedDescription)
            responseError = error
            switch error{
            case is DecodingError:
                responseError = NetworkError.parseDataError
            case NetworkError.InvalidDataResponseError:
                responseError = NetworkError.InvalidDataResponseError
            case NetworkError.InvalidStatusCodeResponse:
                responseError = NetworkError.InvalidStatusCodeResponse
            case NetworkError.dataNotFoundError:
                responseError = NetworkError.dataNotFoundError
            case NetworkError.InvalidURLError:
                responseError = NetworkError.InvalidURLError
            default:
                responseError = NetworkError.InvalidDataResponseError
            }
        }
    }
    
    private func buildURL(baseURL: String, queryParams: [String: String]) -> String? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url?.absoluteString ?? baseURL
    }
    
}

struct ApiKeyManager{
    static func valueForKey(key: String) -> String{
        guard let filePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else{
            return ""
        }
        guard let plist = NSDictionary(contentsOfFile: filePath) else {
            
            return ""
        }
        return plist[key] as? String ?? ""
    }
}
