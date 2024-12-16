//
//  ForecastView.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/12/24.
//

import SwiftUI
import NetworkPackage

struct ForecastView: View {
    @State private var selection = 0

    @StateObject var viewModel = WeatherViewModel(networkManager: NetworkMnager())
    var body: some View {
        ScrollView{
            VStack(spacing: 2) {
                //MARK: Segmented control
                SegmentedControl(selection: $selection)
//                ForecastCards()
                //MARK: Forecast cards
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 12){
                        
                        if selection == 0 {
//                            let forecastKeys = Array(viewModel.dailyForecast.keys.sorted())
//                            let forecastKeys = viewModel.dailyForecast.keys.sorted()

//                            ForEach(forecastKeys, id: \.self){ date in
//                                if let forecast = viewModel.dailyForecast[date]{
//                                    ForecastCards(forecast: forecast, formattedDate: viewModel.formattedDate(from: forecast.dt_txt))
//                                }
//                            }
                        }else{
//                            let groupedKeys = Array(viewModel.groupedForecastByDay.keys)
//                            let groupedKeys = viewModel.groupForecastByDay.keys.sorted()
//                            ForEach(groupedKeys, id: \.self) { date in
//                                if let forecast = viewModel.groupedForecastByDay[date]{
//                                    if let firstForecast = forecast.first{
//                                        ForecastCards(forecast: firstForecast)
//                                    }
//                                }
//                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                }
            }
            
        }
        .background(Blur(radius: 25, opaque: true))
        .background(Color.bottomSheetBackground)
        .clipShape(RoundedRectangle(cornerRadius: 44))
            .overlay {
                //MARK: Bottom Sheet Inner shadow
                RoundedRectangle(cornerRadius: 44)
                    .stroke(.white, lineWidth: 1)
                    .blendMode(.overlay)
                    .offset(y:1)
                    .blur(radius: 0)
                    .mask {
                        RoundedRectangle(cornerRadius: 44)
                    }
                //MARK: Bottom sheet separator
                Divider()
                    .blendMode(.overlay)
                    .background(Color.bottomSheetBorderTop)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .clipShape(RoundedRectangle(cornerRadius: 44))
            }
            .overlay {
                //MARK: Drag indicator
                RoundedRectangle(cornerRadius: 10)
                    .fill(.black.opacity(0.3))
                    .frame(width: 48, height: 5)
                    .frame(height: 20)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .onAppear{
                let forecastKeys = viewModel.dailyForecast.keys.sorted()
                print("Daily Forecast Keys: \(forecastKeys)") // Debug here
            }
    }
        
}

#Preview {
    ForecastView()
        .background(Color.background)
    
        .preferredColorScheme(.dark)
}
