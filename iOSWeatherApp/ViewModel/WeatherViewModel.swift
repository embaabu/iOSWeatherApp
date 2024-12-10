//
//  WeatherViewModel.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/9/24.
//

import Foundation
import NetworkPackage
import Combine

class WeatherViewModel: ObservableObject{
    let networkManager: Network
    @Published var weatherData = [ResponseBody]()
    @Published var responseError: Error?
    @Published var searchText = ""
    
    private var cancellable = Set<AnyCancellable>()
    
    init(networkManager: Network) {
        self.networkManager = networkManager

    }
    
    func getWeatherData() async{
        
    }
    
}
