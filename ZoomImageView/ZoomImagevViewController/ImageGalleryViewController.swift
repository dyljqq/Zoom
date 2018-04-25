//
//  ImageGalleryViewController.swift
//  ZoomImageView
//
//  Created by 季勤强 on 2018/4/20.
//  Copyright © 2018年 dyljqq. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController, UIViewControllerTransitioningDelegate {
  
  static func show(urlStrings: [String], originFrame: CGRect, at index: Int, target viewController: UIViewController) {
    let urls = urlStrings.compactMap { URL(string: $0) }
    let vc = ImageGalleryViewController(urls: urls, selected: index)
    vc.originImageViewFrame = originFrame
    
    showMask(originFrame: originFrame, url: urls[index]) { maskView, maskImageView in
      vc.finalImageViewFrame = maskImageView.frame
      viewController.present(vc, animated: true) {
        maskView.removeFromSuperview()
        maskImageView.removeFromSuperview()
      }
    }
  }
  
  let urls: [URL]
  let selectedIndex: Int
  
  fileprivate var selectedURL: URL? {
    guard selectedIndex >= 0 && selectedIndex < urls.count else { return nil }
    return urls[selectedIndex]
  }
  
  fileprivate var originImageViewFrame: CGRect = CGRect.zero
  fileprivate var finalImageViewFrame: CGRect = CGRect.zero
  
  private let cellIdentifier = "\(ImageGalleryCell.classForCoder())"
  
  lazy var flowLayout: UICollectionViewFlowLayout = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.scrollDirection = .horizontal
    return flowLayout
  }()
  
  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: self.flowLayout)
    collectionView.backgroundColor = .black
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.dataSource = self
    collectionView.delegate = self
    
    collectionView.register(ImageGalleryCell.classForCoder(), forCellWithReuseIdentifier: cellIdentifier)
    
    return collectionView
  }()
  
  init(urls: [URL], selected index: Int) {
    self.urls = urls
    self.selectedIndex = index
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  private func setup() {
    view.backgroundColor = UIColor.black
    view.addSubview(collectionView)
  }

}

extension ImageGalleryViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return urls.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ImageGalleryCell
    cell.render(url: urls[indexPath.row], tapped: { [weak self] in
      guard let strongSelf = self, let url = strongSelf.selectedURL else { return }
      strongSelf.dismiss(url: url)
    })
    return cell
  }
}

extension ImageGalleryViewController: UICollectionViewDelegate {

}

extension ImageGalleryViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.bounds.size
  }
  
}

// private method & present
extension ImageGalleryViewController {
  
  fileprivate static func addMaskView(originFrame: CGRect, url: URL) -> (UIView, UIImageView)? {
    guard let window = UIApplication.shared.keyWindow else { return nil }
    
    let maskView = renderMaskView()
    let maskImageView = renderImageView(with: originFrame, and: url)
    
    window.addSubview(maskView)
    window.addSubview(maskImageView)
    
    return (maskView, maskImageView)
  }
  
  fileprivate static func showMask(originFrame: CGRect, url: URL, completionHandler: @escaping (UIView, UIImageView) -> ()) {
    guard let (maskView, maskImageView) = addMaskView(originFrame: originFrame, url: url) else { return }
    
    let imageSize = originFrame.size.resize()
    
    UIView.animate(withDuration: 0.3, animations: {
      maskView.backgroundColor = .black
      maskImageView.frame = CGRect(origin: CGPoint(x: 0, y: (UIScreen.main.bounds.height - imageSize.height) / 2), size: imageSize)
    }, completion: { _ in
      completionHandler(maskView, maskImageView)
    })
  }
  
  fileprivate static func renderMaskView() -> UIView {
    let maskView = UIView(frame: UIScreen.main.bounds)
    maskView.backgroundColor = .clear
    return maskView
  }
  
  fileprivate static func renderImageView(with frame: CGRect, and url: URL) -> UIImageView {
    let imageView = UIImageView(frame: frame)
    imageView.backgroundColor = .clear
    imageView.contentMode = .scaleAspectFit
    imageView.kf.setImage(with: url)
    return imageView
  }
}

// private method & dismiss
extension ImageGalleryViewController {
  
  fileprivate func dismiss(url: URL) {
    guard let (maskView, maskImageView) = ImageGalleryViewController.addMaskView(originFrame: finalImageViewFrame, url: url) else { return }
    
    maskView.backgroundColor = .black
    self.dismiss(animated: false, completion: nil)
    
    UIView.animate(withDuration: 0.3, animations: {
      maskView.backgroundColor = UIColor.clear
      maskImageView.frame = self.originImageViewFrame
    }, completion: { _ in
      maskView.removeFromSuperview()
      maskImageView.removeFromSuperview()
    })
  }
  
}

extension CGSize {
  
  var isZero: Bool {
    return width == 0 || height == 0
  }
  
  func resize() -> CGSize {
    guard !isZero else { return CGSize(width: 100, height: 100) }
    let screenSize = UIScreen.main.bounds.size
    let height = self.height * screenSize.width / self.width
    return CGSize(width: screenSize.width, height: height)
  }
  
}
