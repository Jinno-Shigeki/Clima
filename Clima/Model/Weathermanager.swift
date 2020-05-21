//
//  Weathermanager.swift
//  Clima
//
//  Created by 神野成紀 on 2020/03/22.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
     func didUpdateWeather(_ weatherManeger:WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}
struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=307ebc87a814820ba47a3fc808af392f&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func currentWeather(latitude: CLLocationDegrees,longitude: CLLocationDegrees){
        let urlstring = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlstring)
    }
    
    func fetchweather(cityName: String){
           let urlstring = "\(weatherURL)&q=\(cityName)"
           performRequest(with: urlstring)
    }
    
    func performRequest(with urlstring: String){
        
        if let url = URL(string: urlstring){
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.perseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    func perseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodeData =  try decoder.decode(WeatherData.self, from:weatherData )
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            let weather = WeatherModel(conditionID: id, cityName: name, temprature: temp)
            print(weather.conditionID)
            return weather
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
