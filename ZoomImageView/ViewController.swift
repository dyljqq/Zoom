//
//  ViewController.swift
//  ZoomImageView
//
//  Created by 季勤强 on 2018/4/20.
//  Copyright © 2018年 dyljqq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  let imageView = UIImageView(frame: CGRect(x: 50, y: 100, width: 250, height: 250))
  
  let urls = [
    "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-1.jpg",
    "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-2.jpg",
    "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-3.jpg"
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    view.addSubview(imageView)
    
    imageView.kf.setImage(with: URL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-1.jpg")!)
    
    imageView.isUserInteractionEnabled = true
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
  }
  
  @objc func tapped() {
    ImageGalleryViewController.show(urlStrings: urls, originFrame: imageView.frame, at: 0, target: self)
  }

}
