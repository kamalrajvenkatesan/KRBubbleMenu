//
//  KRBubbleMenuItem.swift
//  PopUpMenu
//
//  Created by kamalraj venkatesan on 14/12/17.
//  Copyright © 2017 kamalraj. All rights reserved.
//

import UIKit

import UIKit

public class KRBubbleMenuItem: UIView {

  typealias SelectedBlock = () -> Void


  var imageView: UIImageView?
  var selected: Bool?
  var selecteBlock: SelectedBlock?




  init(image: UIImage, selectedImage: UIImage, selectedBlock: @escaping SelectedBlock) {

    super.init(frame: CGRect(x: 0, y: 0, width: MENU_ITEM_LENGTH, height: MENU_ITEM_LENGTH))

    self.imageView = UIImageView()
    self.imageView?.frame = self.bounds
    self.imageView?.image = image
    self.imageView?.highlightedImage = selectedImage
    self.addSubview(self.imageView!)

    self.selecteBlock = selectedBlock

  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  func setSelected(selected: Bool) {
    self.selected = selected
    self.imageView?.isHighlighted = selected
  }

}
