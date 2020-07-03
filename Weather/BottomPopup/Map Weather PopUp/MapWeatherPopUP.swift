//
//  MapWeatherPopUP.swift
//  Weather
//
//  Created by Lukas Bimba on 7/3/20.
//  Copyright © 2020 Lukas Bimba. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class MapWeatherPopUP: UITableViewController, CLLocationManagerDelegate {

    @IBOutlet var City: UILabel!
    @IBOutlet var Weather: UILabel!
    @IBOutlet var Degress: UILabel!
    
    var locationManager = CLLocationManager()
    
    var lat: Double?
    var long: Double?
    
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //requestLocationPermision()
        
        print(lat)
        print(long)
        print("Pringting the latitude and longitude here")
        retrieveCurrentWeatherAtLat()
    }
    
    let APIKey = "4bb67b1bd55ba91a7e2e5d0a3dd6fd48"

    //  Sending the request to Open Weather
    func retrieveCurrentWeatherAtLat() {
        let url = "https://api.openweathermap.org/data/2.5/weather?APPID=\(APIKey)"
        let params = ["lat": lat, "lon": long]
        print("Sending request... \(url)")
        let request = AF.request(url, method: .get, parameters: params, encoding: URLEncoding(destination: .queryString)).responseJSON { (response) in
            print("Got response from server: \(response)")
            switch response.result {
            case .success(let json):
                
                let json = JSON(json)
                
                let CityName = json["name"].stringValue
                let WeatherDegrees = json["main"]["temp"].stringValue
                let WeatherSummary = json["weather"].arrayValue.map{$0["description"].stringValue}
                let Weather = WeatherSummary.debugDescription
                self.City.text = CityName
                self.Weather.text = Weather
                self.Degress.text = WeatherDegrees
                
                print("Success: \(json)") //test
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        request.resume()
    }

    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func getPopupHeight() -> CGFloat {
        return height ?? CGFloat(600)
    }
    
    func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
    func getPopupPresentDuration() -> Double {
        return presentDuration ?? 1.0
    }
    
    func getPopupDismissDuration() -> Double {
        return dismissDuration ?? 1.0
    }
    
    func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
    }

    func showAlert(_ message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
