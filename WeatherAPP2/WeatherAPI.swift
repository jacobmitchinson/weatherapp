//
//  WeatherAPI.swift
//  WeatherAPP2
//
//  Created by DeepThought on 30/09/2016.
//  Copyright © 2016 Jake. All rights reserved.
//

import Foundation

enum WeatherResult<ReturnType, E where E: ErrorProtocol> {
    case success(ReturnType)
    case failure(E)
}

struct WeatherAPI {
    
    internal enum Error: ErrorProtocol {
        case noData
        case urlSessionError(ErrorProtocol)
        case serializationError(ErrorProtocol)
        case mappingToDictionaryError
        case parseWeatherError
    }
    
    private static let baseURLString = "http://api.openweathermap.org/data/2.5/"
    private static let apiKey = "339c37372023768b699f0ced3f54f2f8"
    
    static func fetchWeather(location:String, completion:(WeatherResult<Weather, Error>) -> Void) {
        
        let parameters = ["q":location, "appid":apiKey]
        let url = createURL(parameters: parameters)
        let request = URLRequest(url:url)
        
        URLSession.shared().dataTask(with: request) { (data, response, error) -> Void in
            let parsedJSON = parseJSON(data: data, response: response, error: error)
            
            switch parsedJSON {
            case .success(let json):
                
                guard let weather = Weather(json: json) else {
                    completion(.failure(.parseWeatherError))
                    return
                }
                
                completion(.success(weather))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func parseJSON(data:Data?, response:URLResponse?, error:ErrorProtocol?) -> WeatherResult<[String:Any], Error> {
        
        if let error = error {
            return .failure(.urlSessionError(error))
        }
        
        guard let data = data else {
            return .failure(.noData)
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = json as? [String:Any] else {
                return .failure(.mappingToDictionaryError)
            }
            
            return .success(jsonDictionary)
        } catch {
            return .failure(.serializationError(error))
        }
        
    }
    
    private static func createURL(parameters:[String: String]) -> URL {
        var components = URLComponents(string:baseURLString + "weather")
        
        if parameters.count > 0 {
            components?.queryItems = parameters.map {URLQueryItem(name:$0, value:$1)}
        }

        return components!.url!
    }
}
