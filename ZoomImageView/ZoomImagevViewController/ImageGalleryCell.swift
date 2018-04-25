//
//  ImageGalleryCell.swift
//  ZoomImageView
//
//  Created by 季勤强 on 2018/4/20.
//  Copyright © 2018年 dyljqq. All rights reserved.
//

import UIKit

class ImageGalleryCell: UICollectionViewCell {
  
  let zoomImageView: ZoomImageView
  
  override init(frame: CGRect) {
    zoomImageView = ZoomImageView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
    super.init(frame: frame)
    
    addSubview(zoomImageView)
  }
  
  func render(url: URL, tapped: @escaping () -> ()) {
    zoomImageView.render(url: url)
    
    zoomImageView.singleTapClosure = {
      tapped()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
