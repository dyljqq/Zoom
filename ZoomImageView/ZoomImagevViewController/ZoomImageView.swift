//
//  ZoomImageView.swift
//  ZoomImageView
//
//  Created by 季勤强 on 2018/4/20.
//  Copyright © 2018年 dyljqq. All rights reserved.
//

import UIKit
import Kingfisher

fileprivate extension Selector {
  static let single = #selector(ZoomImageView.singleTap)
  static let double = #selector(ZoomImageView.doubleTap)
}

class ZoomImageView: UIScrollView {
  
  var singleTapClosure: (() -> Void)?
  
  private lazy var zoomImageView: UIImageView = {
    let imageView = UIImageView(frame: CGRect.zero)
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = true
    imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render(url: URL) {
    downloadImage(url: url)
  }
  
  @objc func singleTap(_ tapGestureRecoginzer: UITapGestureRecognizer) {
    if let closure = singleTapClosure {
      closure()
    }
  }
  
  @objc func doubleTap(_ tapGestureRecoginzer: UITapGestureRecognizer) {
    var point = tapGestureRecoginzer.location(in: tapGestureRecoginzer.view)
    point.x = zoomImageView.frame.midX
    
    let scale = (maximumZoomScale - zoomScale) > 0.01 ? maximumZoomScale : 1.0
    let size = CGSize(width: frame.width / scale, height: frame.height / scale)
    let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2)
    self.zoom(to: CGRect(origin: origin, size: size), animated: true)
  }
  
  private func setup() {
    
    delegate = self
    maximumZoomScale = 2.0
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    addSubview(zoomImageView)
    
    let singleTap = UITapGestureRecognizer(target: self, action: .single)
    addGestureRecognizer(singleTap)
    
    let doubleTap = UITapGestureRecognizer(target: self, action: .double)
    doubleTap.numberOfTapsRequired = 2
    addGestureRecognizer(doubleTap)
    
    singleTap.require(toFail: doubleTap)
    
  }
  
  private func downloadImage(url: URL) {
    zoomImageView.kf.setImage(with: url, completionHandler: { (image: UIImage?, error: NSError?, cacheType: CacheType, imageURL: URL?) in
      guard let image = image else { return }
      guard self.frame.width > 0 && self.frame.height > 0 else { return }
      
      let size = image.size
      let radio = self.frame.width * size.height / (self.frame.height * size.width)
      self.maximumZoomScale = max(radio, 1 / radio, 2.0)
      let newSize = self.resize(size)
      self.zoomImageView.bounds = CGRect(origin: CGPoint.zero, size: newSize)
      self.zoomImageView.center = self.zoomImageViewCenter      
    })
  }
  
}

extension ZoomImageView {
  
  fileprivate var zoomImageViewCenter: CGPoint {
    let centerX = contentSize.width > bounds.width ? contentSize.width / 2 : self.center.x
    let centerY = contentSize.height > bounds.height ? contentSize.height / 2 : self.center.y
    return CGPoint(x: centerX, y: centerY)
  }
  
  func resize(_ size: CGSize) -> CGSize {
    guard !size.isZero else { return CGSize(width: 100, height: 100) }
    let screenSize = UIScreen.main.bounds.size
    let height = size.height * screenSize.width / size.width
    return CGSize(width: screenSize.width, height: height)
  }
  
}

extension ZoomImageView: UIScrollViewDelegate {
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return zoomImageView
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    zoomImageView.center = zoomImageViewCenter
  }
  
}
