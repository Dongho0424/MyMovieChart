//
//  TheaterViewController.swift
//  MyMovieChart
//
//  Created by dongho on 2021/03/05.
//

import Foundation
import UIKit
import MapKit

class TheaterViewController: UIViewController{
    // 전달되는 데이터를 받을 변수
    var param: NSDictionary!
    
    @IBOutlet var map: MKMapView!
    
    override func viewDidLoad() {
        // 타이틀 지정
        self.navigationItem.title = self.param["상영관명"] as? String
        
        // 1. 위도와 경도 추출해서 double로
        let latitude = (param["위도"] as! NSString).doubleValue
        let longitude = (param["경도"] as! NSString).doubleValue
        // 2. 위도와 경도를 인수로 하는 2D 위치 정보 객체 정의
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 3. 지도에 표현될 반경: 값의 단위는 미터
        let regionRadius : CLLocationDistance = 100
        // 4. 거리를 반영한 지역 정보를 조합한 지도 데이터
        let coordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        // 5. map 변수에 연결된 지도 객체에 데이터를 전달하여 화면에 표시
        self.map.setRegion(coordinateRegion, animated: false)
        
        // 위치 표시해주는 point
        let point = MKPointAnnotation()
        
        point.coordinate = location
        
        self.map.addAnnotation(point)
    }
    
}
