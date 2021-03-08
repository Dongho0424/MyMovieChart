//
//  TheaterListViewController.swift
//  MyMovieChart
//
//  Created by dongho on 2021/03/05.
//

import Foundation
import UIKit

class TheaterListViewController: UITableViewController{
    // API를 통해 불러온 데이터를 저장할 변수
    var tList = [NSDictionary]()
    
    // API가 구려서 시작하는 페이지 위치를 잡아줘야함
    var startPoint = 0
    
    override func viewDidLoad() {
        self.callTheaterAIP()
    }
    
    // API에서 데이터 긁어오는 메소드
    func callTheaterAIP() {
        
        // 1. URL 구성하는 값들
        let requestURI = "http://swiftapi.rubypaper.co.kr:2029/theater/list"
        let sList = 100
        let type = "json"
        
        // 2. URL 객체
        let urlObj = URL(string: "\(requestURI)?s_page=\(startPoint)&s_list=\(sList)&type=\(type)")
        
        do {
            // 3. API 호출하고 결과값을 인코딩된 문자열로 받아오기
            // 0x80_000_422 은 EUC-KR에 해당하는 인코딩
            let stringdata = try NSString(contentsOf: urlObj!, encoding: 0x80_000_422)
            
            // 4. 받아온 문자열 데이터를 UTF-8로 인코딩한 DATA로 바꿈
            let encdata = stringdata.data(using: String.Encoding.utf8.rawValue)
            
            // 4.5. 로그
//            let log = NSString(
            NSLog("apiData: \(stringdata)")
            
            do {
                // 5. JSON 객체를 파싱하여 NSObject 객체로 만듦
                let apiArray = try JSONSerialization.jsonObject(with: encdata!, options: []) as? NSArray
                
                // 6. 읽어온 데이터를 순회하면서 list에 값 채우기
                for obj in apiArray! {
                    tList.append(obj as! NSDictionary)
                }

            } catch {
                alert("데이터 분석이 실패했습니다.")
            }
            
            startPoint += sList
            
        } catch {
            alert("데이터를 불러오는데 실패했습니다")
        }
                // 7. 읽어올 다음 페이지에 대한 시작 번호를 지정해줌
    }
    
    // tableView가 viewDidLoad 전 후 인지 판단
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 각 셀의 데이터
        let data = self.tList[indexPath.row]
        
        // reuse queue 에서 꺼내와서 데이터 넣기
        let cell = tableView.dequeueReusableCell(withIdentifier: "tCell") as! TheaterCell
        
        cell.tName.text = data["상영관명"] as? String
        cell.tContact.text = data["연락처"] as? String
        cell.tAddress.text = data["소재지도로명주소"] as? String
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_map"{
            let path = self.tableView.indexPath(for: sender as! UITableViewCell)
            
            let data = self.tList[path!.row]
            
            (segue.destination as? TheaterViewController)?.param = data
        }
    }
}
