//
//  DetailViewController.swift
//  MyMovieChart
//
//  Created by dongho on 2021/03/04.
//

import Foundation
import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    @IBOutlet var wv: WKWebView!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var mvo: MovieVO!
    
    override func viewDidLoad() {
        NSLog("linkurl= \(self.mvo.detail!)")
        
        self.wv.navigationDelegate = self
        
        // 너가 제목같이 달아놓은 것이 바로 navigationItem
        let navibar = self.navigationItem
        navibar.title = self.mvo.title
        
        // URL Request 인스턴스를 생성한다.
        let url = URL(string: (self.mvo.detail)!)
        let request = URLRequest(url: url!)
        
        // loadRequest 메소드를 호출하면서 req를 인자값으로 전달한다.
        self.wv.load(request)
    }
}
// MARK: - WKNavigationDelegate 구현
extension DetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.spinner.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.spinner.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating()
        
        self.alert("상세 페이지를 읽어오지 못했습니다."){
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}
// MARK:- UIViewController에 심플한 경고창 함수 정의용 익스텐션
extension UIViewController {
    func alert(_ message: String, onClick: (() -> Void)? = nil){
        let controller = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "ok", style: .cancel){
            (_) in
            onClick?()
        })
        
        DispatchQueue.main.async {
            self.present(controller, animated: true)
        }
    }
}
