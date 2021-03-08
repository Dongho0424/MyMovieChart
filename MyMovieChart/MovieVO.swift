//
//  MovieVO.swift
//  MyMovieChart
//
//  Created by dongho on 2021/03/03.
//

import Foundation
import UIKit

class MovieVO {
    var thumbnail: String? // image 주소는 스트링이다.
    var title: String?
    var description: String?
    var detail: String?
    var opendate: String?
    var rating: Double?
    
    // 썸네일 이미지 자체를 담아버릴 UIImage 객체
    var thumbnailImage: UIImage?
}
