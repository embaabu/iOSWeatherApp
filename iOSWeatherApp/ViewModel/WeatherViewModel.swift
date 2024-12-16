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

class WeatherViewModel:  ObservableObject{
    let networkManager: Network
    @Published var forecast : ForecastResponse?{
        didSet{
            groupForecast()
            extractDailyForecast()
        }
    }
    @Published var currentWeather: Forecast?
    @Published var isLoading: Bool = false
    @Published var groupedForecastByDay : [[Forecast]] = []
    @Published var dailyForecastList : [Forecast] = []
    @Published var responseError: Error?
    @Published var searchText = ""
    
    private var cancellable = Set<AnyCancellable>()
    
    var groupForecastByDay = [String: [Forecast]]()
    var dailyForecast = [String: Forecast]()
    
    init(networkManager: Network) {
        self.networkManager = networkManager

    }
    func bindLocationManager(_ locationManager: LocationManager){
        locationManager.onLocationChange = { [weak self] location in
            Task {
                await self?.getWeatherData(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
    
    func getWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async{
        let apiKey = ApiKeyManager.valueForKey(key: "WeatherAPIKey")
        print("api key is\(apiKey)")
        let url = "https://api.openweathermap.org/data/2.5/forecast"
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
            print("\(fullUrl)")

            let weatherForecast = try await self.networkManager.getDataFromUrl(url: fullUrl, modelType: ForecastResponse.self)
//            print("\(weatherForecast)")
            DispatchQueue.main.async { [ weak self ] in
                self?.forecast = weatherForecast
                self?.isLoading = false
                self?.currentWeather = weatherForecast.list.first
            }
            
            
        }catch{
            DispatchQueue.main.async { [weak self ] in
                print("Error fetching data \(error.localizedDescription)")
                self?.responseError = error
                switch error{
                case is DecodingError:
                    self?.responseError = NetworkError.parseDataError
                case NetworkError.InvalidDataResponseError:
                    self?.responseError = NetworkError.InvalidDataResponseError
                case NetworkError.InvalidStatusCodeResponse:
                    self?.responseError = NetworkError.InvalidStatusCodeResponse
                case NetworkError.dataNotFoundError:
                    self?.responseError = NetworkError.dataNotFoundError
                case NetworkError.InvalidURLError:
                    self?.responseError = NetworkError.InvalidURLError
                default:
                    self?.responseError = NetworkError.InvalidDataResponseError
                }
            }

        }
    }
    
    private func buildURL(baseURL: String, queryParams: [String: String]) -> String? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url?.absoluteString ?? baseURL
    }
    
    
    private func groupForecast() {
        var groupedData = [String: [Forecast]]()

        guard let forecastList = forecast?.list else {
            print("No forecast data available")
            return
        }

        for item in forecastList {
            let date = String(item.dt_txt.prefix(10)) // Extract date
            groupedData[date, default: []].append(item)
        }

        groupForecastByDay = groupedData

        // Update groupedForecast for the view
//        groupedForecastByDay = Array(groupedData.values)

        print("Grouped Data: \(groupedData)")
    }
    
    private func extractDailyForecast(){
        var dailyData = [String:Forecast]()
        
        for(date, forecasts) in groupForecastByDay{
            if let firstForecast = forecasts.first{
                dailyData[date] = firstForecast
            }
        }
        dailyForecast = dailyData
        dailyForecastList = Array(dailyData.values)
        print("***Daily Forecast: \(dailyForecast)")
    }
    
    func dailyHighLow(for date: String) -> (high: Double, low: Double) {
        guard let forecastsForDay = groupForecastByDay[date] else {
            // Return default values if the date is not found
            return (0, 0)
        }
        
        let highTemp = forecastsForDay.max { $0.main.tempMax < $1.main.tempMax }?.main.tempMax ?? 0
        let lowTemp = forecastsForDay.min { $0.main.tempMin < $1.main.tempMin }?.main.tempMin ?? 0
        
        return (highTemp, lowTemp)
    }
    // Helper to format date string
        func formattedDate(from dateString: String) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Match the incoming format
            
            if let date = dateFormatter.date(from: dateString) {
                // Check if it's a 3-hour interval forecast
                let calendar = Calendar.current
                _ = Date()
                
                // If the date is today, show time (e.g., "9AM")
                if calendar.isDateInToday(date) {
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "ha" // Hour + AM/PM format
                    return timeFormatter.string(from: date)
                }
                
                // Otherwise, show the weekday (e.g., "Tue")
                let weekdayFormatter = DateFormatter()
                weekdayFormatter.dateFormat = "EEE" // Short weekday name
                return weekdayFormatter.string(from: date)
            }
            
            // Fallback if parsing fails
            return "N/A"
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

