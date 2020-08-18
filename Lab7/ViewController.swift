//
//  ViewController.swift
//  Lab7
//
//  Created by Noah Korner on 4/3/20.
//  Copyright © 2020 asu. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var textArea: UITextView!
    struct earthquakes: Decodable {
        let earthquakes: [earthquake]
       }
       
       struct earthquake: Decodable {
        let datetime: String?
        let magnitude: Double?
        //let magnitude: String?
       }
    
    var newCity:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.textArea.text! = ""
        self.textArea.isEditable = false;
    }

    @IBAction func newCityButton(_ sender: Any) {
        //Alert Message "Input City Name"
        let alert = UIAlertController(title: "Find Earthquake Information: ", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input city name here..."
        })
        
        //Alert Message "Input City Name" OK action handler
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            //Store user inputted city
            self.newCity = alert.textFields!.first!.text!
            print("New City Request: \(self.newCity)") //print new city request to console
            
            //Call getLocation to find Latitude and Longitude
            self.getLocation(cityName: self.newCity)
        }))
        
        //Present Alert Message "Input City Name"
        self.present(alert, animated: true)
    }
    
    private func getLocation(cityName : String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location!.coordinate.latitude
            var lon = placemark?.location!.coordinate.longitude
            print("Lat: \(lat!), Lon: \(lon!)")
            
            var north = lat! + 10
            var south = lat! - 10
            var east = lon! - 10
            var west = lon! + 10
            print("\(north)\(south)\(east)\(west)")
            self.retrieveEarthquakeInfo(north:north, south:south, east:east, west:west)
        }
    }
    
    private func retrieveEarthquakeInfo(north:Double, south:Double, east:Double, west:Double){
        textArea.text! = ""
        let url = URL(string: "http://api.geonames.org/earthquakesJSON?north=\(north)&south=\(south)&east=\(east)&west=\(west)&username=nkorner")
        let urlSession = URLSession.shared
              
              
              let jsonQuery = urlSession.dataTask(with: url!, completionHandler: { data, response, error -> Void in
                  if (error != nil) {
                      print(error!.localizedDescription)
                  }
                  var err: NSError?
                  
                  let decoder = JSONDecoder()
                  let jsonResult = try! decoder.decode(earthquakes.self, from: data!)
                                
                  if (err != nil) {
                      print("JSON Error \(err!.localizedDescription)")
                  }

                var count:Int = 1
                print("10 most recent earthquakes:\n")
                for each in jsonResult.earthquakes{
                    DispatchQueue.main.async {
                        if count <= 10{
                            print("Earthquake \(count):\n\tDatetime: \(String(each.datetime!))\n\tMagnitude: \(String(each.magnitude!))\n")
                            self.textArea.text! += "Earthquake \(count):\n\tDatetime: \(String(each.datetime!))\n\tMagnitude: \(String(each.magnitude!))\n"
                            count += 1
                        }
                    }
                }
              })
              jsonQuery.resume()
    }
    
}

