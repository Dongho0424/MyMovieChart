//
//  ListViewController.swift
//  MyMovieChart
//
//  Created by dongho on 2021/03/03.
//

import Foundation
import UIKit

class ListViewController: UITableViewController {
    
    var list = [MovieVO]()
    
    var page = 1
    
    @IBOutlet var moreBtn: UIButton!
    
    @IBAction func more(_ sender: Any) {
        self.page += 1
        
        self.callMovieAPI()
        
        self.tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        self.callMovieAPI()
        
    }
    
    func callMovieAPI() {
        // 1. hoppin API 호출을 위한 URI을 생성
        let url = "http://swiftapi.rubypaper.co.kr:2029/hoppin/movies?version=1&page=\(self.page)&count=30&genreId=&order=releasedateasc"
        let apiURI: URL! = URL(string: url)
        
        // 2. REST API를 호출
        // 이것만 해도 JSON이 바로 되는 이유는 apiURI가 애초에 UTF-8로 인코딩되어있었음
        // 한글까지 문제없이 처리할 수 있는 호환 형식: UTF-8
        let apidata = try! Data(contentsOf: apiURI)
        
        // 3. log
        let log = NSString(data: apidata, encoding: String.Encoding.utf8.rawValue) ?? "데이터가 없습니다."
        NSLog("API Result:\(log)")
        
        do{
            // 4. JSON 객체를 파싱하여 NSDictionary 객체로 받음
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary
                
            // 5. 데이터 구조에 따라 차례대로 캐스팅하여 읽어오기/
            
            let hoppin = apiDictionary["hoppin"] as! NSDictionary
            let movies = hoppin["movies"] as! NSDictionary
            let movie = movies["movie"] as! NSArray
            
            // 6. iterator로 api 데이터를 movieVO에 저장
            for row in movie {
                let r = row as! NSDictionary
                
                let mvo = MovieVO()
                
                mvo.title = r["title"] as? String
                mvo.description = r["genreNames"] as? String
                mvo.thumbnail = r["thumbnailImage"] as? String
                mvo.detail = r["linkUrl"] as? String
                mvo.rating = (r["ratingAverage"] as! NSString).doubleValue
                
//                // 웹상에 있는 이미지를 읽어와 UIImage 객체로 생성
//                // ㅈㄴ 오래 걸리는 과정
//                // 초기에 스플래시 화면이 엄청 느려질 수 있음
//                let url: URL! = URL(string: mvo.thumbnail!)
//                let imageData = try! Data(contentsOf: url)
//                mvo.thumbnailImage = UIImage(data: imageData)
                
                self.list.append(mvo)
            }
            
            // 7. 전체 데이터 카운트를 얻는다
                
            let totalCount = (hoppin["totalCount"] as! NSString).integerValue
            
            // 8. totalCount가 읽어온 데이터 크기와 같거나 클 경우 더보기 버튼을 막는다.
            
            if self.list.count >= totalCount {
                self.moreBtn.isHidden = true
            }
        } catch{
            NSLog("Parse Error!")
        }
    }
    
    func getThumbnailImage(_ index: Int) -> UIImage {
        let mvo = self.list[index]
        
        if let savedImage = mvo.thumbnailImage {
            print("저장된 이미지 사용")
            return savedImage
        } else {
            print("업로딩..")
            let url: URL! = URL(string: mvo.thumbnail!)
            let imageData = try! Data(contentsOf: url)
            mvo.thumbnailImage = UIImage(data: imageData)
            
            return mvo.thumbnailImage!
        }
    }
    
    // iOS가 테이블 뷰의 총 행 개수를 파악하기 위해 내가 적어야 하는 메서드
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    // iOS가 테이블 뷰의 각 셀에 들어갈 항목을 그리기 위해 우리가 적어줌
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.list[indexPath.row]
        
        // 로그 출력
        NSLog("제목: \(row.title!), 호출된 행번호: \(indexPath.row)+")
        
        // cell을 dequeue해서 가져오는데 이때 커스텀 클래스로 다운캐스팅
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! MovieCell
        
        cell.title.text = row.title
        cell.desc.text = row.description
//        cell.opendate.text = row.opendate
        cell.rating.text = "\(row.rating!)"
        // imageView에 image 대입
//        cell.thumbnail.image = UIImage(named: row.thumbnail!)
        
        // 웹상에서 이미지 불러오기
        // 1. 섬네일 경로에 해당하는 url객체 만들고
        // 2. Data(contentsOf:) 객체 만들고
        // 3. UIImage 만듦
        // UIImage의 init의 타입 중 Data가 있기 때문에
        
//        let url: URL! = URL(string: row.thumbnail!)
//        let imageData = try! Data(contentsOf: url)
//        cell.thumbnail.image = UIImage(data: imageData)
        
        // 비동기 방식으로 섬네일 이미지 읽음~~
        DispatchQueue.main.async {
            cell.thumbnail.image = self.getThumbnailImage(indexPath.row)
        }
        
//        cell.thumbnail.image = row.thumbnailImage
        
        return cell
    }
    
    // 유저가 각 테이블 셀 클릭했을 때
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("선택된 행은 \(indexPath.row) 번째 행입니다.")
    }
}
// MARK: - 화면 전환 시 값을 넘겨주기 위한 세그웨이 관련 처리
extension ListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "segue_detail" {
            // 사용자가 클릭한 행을 찾아낸다.
            let path = self.tableView.indexPath(for: sender as! MovieCell)
            
            // 행 정보를 통해 선택된 영화 데이트 찾음
            // 목적지 뷰 컨트롤로의 mvo 변수에 대입
            let detailVC = segue.destination as? DetailViewController
            detailVC?.mvo = self.list[path!.row]
        }
    }
}

