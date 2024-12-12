//
//  iOSWeatherAppApp.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/9/24.
//

import SwiftUI

@main
struct iOSWeatherAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(weather: ResponseBody(coord: iOSWeatherApp.Coord(lon: -122.4082, lat: 37.7874), weather: [iOSWeatherApp.WeatherData(id: 803, main: "Clouds", description: "broken clouds", icon: "04d")], base: "stations", main: iOSWeatherApp.Main(temp: 14.3, feelsLike: 13.3, tempMin: 12.64, tempMax: 15.92, pressure: 1018, humidity: 58, seaLevel: 1018, grndLevel: 1014), visibility: 10000, wind: iOSWeatherApp.Wind(speed: 4.12, deg: 310, gust: nil), rain: nil, clouds: iOSWeatherApp.Clouds(all: 75), dt: 1733960365, sys: iOSWeatherApp.Sys(type: 2, id: 2007646, country: "US", sunrise: 1733930134, sunset: 1733964662), timezone: -28800, id: 5391959, name: "San Francisco", cod: 200))
        }
    }
}
