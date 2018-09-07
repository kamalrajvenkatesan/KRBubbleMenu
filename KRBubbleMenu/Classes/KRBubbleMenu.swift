//
//  KRBubbleMenu.swift
//  PopUpMenu
//
//  Created by kamalraj venkatesan on 14/12/17.
//  Copyright © 2017 kamalraj. All rights reserved.
//

import UIKit
import Foundation


let MAX_ANGLE = CGFloat.pi / 2
let MAX_LENGTH: CGFloat = (95)
let LENGTH: CGFloat = (75)
let BOUNCE_LENGTH: CGFloat = (18)
let PULSE_LENGTH: CGFloat = (60)
let MENU_ITEM_LENGTH:CGFloat = (40)

public class KRBubbleMenu: UIView {

  var subMenus: [UIView] = []
  var startImageView: UIImageView?
  var startPoint: CGPoint?

  let titleLabel = UILabel()
  var titleMenu: [String] = []

  init(subMenu: [UIView], startPoint: CGPoint, titles: [String]) {

    super.init(frame: (UIApplication.shared.keyWindow?.frame)!)

    self.frame = (UIApplication.shared.keyWindow?.frame)!
//    self.backgroundColor = UIColor(white: 0.2, alpha: 0.5)

    self.subMenus = subMenu

    self.startImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: MAX_LENGTH, height: MAX_LENGTH))
    self.startImageView?.image = UIImage(named: "center")

    self.startPoint = startPoint

    for menu in self.subMenus {
      menu.center = self.startPoint ?? CGPoint(x: 0, y: 0)
      self.addSubview(menu)
    }

    // Label
    if titles.count > 0 {
      self.layoutLabel(longPressLocation: startPoint)
    }

    self.titleMenu = titles

  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func distanceBetweenXAndY(pointX: CGPoint, pointY: CGPoint) -> CGFloat {

    var distance: CGFloat = 0
    let offsetX = pointX.x - pointY.x
    let offsetY = pointX.y - pointY.y
    distance = sqrt(pow(offsetX, 2) + pow(offsetY, 2))
    return distance
  }


  private func setStartPoint(point: inout CGPoint) {

    point.x = point.x < MENU_ITEM_LENGTH / 2 ? MENU_ITEM_LENGTH / 2 : point.x;
    point.x = point.x > (320 - MENU_ITEM_LENGTH / 2) ? (320 - MENU_ITEM_LENGTH / 2) : point.x;

    self.startPoint = point

    self.startImageView?.center = point

    for menu in self.subMenus {
      menu.center = self.startPoint ?? CGPoint(x: 0, y: 0)
    }
  }

  func show() {
    let window = UIApplication.shared.keyWindow
    window?.addSubview(self)

    self.appear()

  }

  private func appear() {

    for i in 0..<subMenus.count {
      self.plusTheMenuAtIndex(index: i)
    }

  }

  private func plusTheMenuAtIndex(index: Int) {

    guard let startPoint = self.startPoint else {
      return
    }

    let view = self.subMenus[index]

    UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
      let radian = self.readianWith(index: index)
      let y: CGFloat = (LENGTH + BOUNCE_LENGTH) * sin(radian)
      let x: CGFloat = (LENGTH + BOUNCE_LENGTH) * cos(radian)
      view.center = CGPoint(x: startPoint.x + CGFloat(x), y: startPoint.y + CGFloat(y))
    }) { (finished) in

      UIView.animate(withDuration: 0.15, animations: {
        let radian = self.readianWith(index: index)
        let y: CGFloat = LENGTH * sin(radian)
        let x: CGFloat = LENGTH * cos(radian)
        view.center = CGPoint(x: startPoint.x + x, y: startPoint.y + y)
      }, completion: nil)
    }
  }


  private func readianWith(index: Int) -> CGFloat {

    guard let startPoint = self.startPoint else {

      return CGFloat.leastNonzeroMagnitude
    }

    let count = self.subMenus.count


    let valueOne = CGFloat.pi/2 * 3

    let valueTwo = (startPoint.x - 20) / (320 - 20 * 2)

    let startRadian =  valueOne - (valueTwo * CGFloat.pi/2)

    let countForStep = (count > 1) ? count - 1 : 1

    let step = MAX_ANGLE / CGFloat(countForStep)

    return startRadian + CGFloat(index) * step
  }

  func updateLocation(touchedPoint: CGPoint) {

    var closestIndex: Int = 0

    var minDistance = CGFloat.greatestFiniteMagnitude

    // Find the closest menu item

    for i in 0..<self.subMenus.count {

      let floatingPoint = self.floatingPointWith(index: i)

      let distance = self.distanceBetweenXAndY(pointX: touchedPoint, pointY: floatingPoint)

      if (distance < minDistance) {
        minDistance = distance
        closestIndex = i
      }

    }

    for i in 0..<self.subMenus.count {

      let menuItem: KRBubbleMenuItem = self.subMenus[i] as! KRBubbleMenuItem

      if i == closestIndex {
        let floatingPoint = self.floatingPointWith(index: i)
        var currentDistance = distanceBetweenXAndY(pointX: touchedPoint, pointY: floatingPoint)
        currentDistance = currentDistance > MAX_LENGTH ? MAX_LENGTH : currentDistance
        let step = (currentDistance / MAX_LENGTH) * (MAX_LENGTH - LENGTH)


        UIView.animate(withDuration: 0.1, animations: {
          self.moveWith(index: i, offSet: step)
        })

        let distance: CGFloat = distanceBetweenXAndY(pointX: touchedPoint, pointY: floatingPoint)

        // if close enought, heighlight the point
        if (distance < PULSE_LENGTH) {
          menuItem.setSelected(selected: true)
          self.titleLabel.text = self.titleMenu[i]
        } else {
          menuItem.setSelected(selected: false)
          self.titleLabel.text = ""
        }

      } else {
        UIView.animate(withDuration: 0.20, animations: {
          self.setThePosition(index: i)
        }, completion: { (finshed) in
          menuItem.setSelected(selected: false)
        })
      }
    }

  }

  private func floatingPointWith(index: Int) -> CGPoint {

    guard let startPoint = self.startPoint else {
      return CGPoint.zero
    }

    let radian = self.readianWith(index: index)
    let x: CGFloat = CGFloat(MAX_LENGTH * cos(radian))
    let y: CGFloat = CGFloat(MAX_LENGTH * sin(radian))

    let point: CGPoint = CGPoint(x: startPoint.x + x, y: startPoint.y + y)

    return point
  }

  private func moveWith(index: Int, offSet: CGFloat) {

    let menuItem = self.subMenus[index]
    let floating = self.floatingPointWith(index: index)
    var radian = self.readianWith(index: index)
    radian = radian - CGFloat.pi

    let x = floating.x + offSet * cos(radian)
    let y = floating.y + offSet * sin(radian)

    menuItem.center = CGPoint(x: x, y: y)

  }

  private func setThePosition(index: Int) {

    guard let startPoint = self.startPoint else {
      return
    }

    let radian = self.readianWith(index: index)
    let x = LENGTH * cos(radian)
    let y = LENGTH * sin(radian)

    let view = self.subMenus[index]
    view.center = CGPoint(x: startPoint.x + x, y: startPoint.y + y)

  }

  func finished() {

    for i in 0..<self.subMenus.count {
      let menuItem = self.subMenus[i] as! KRBubbleMenuItem

      if (menuItem.selected == true) {
        if ((menuItem.selecteBlock) != nil) {
          menuItem.selecteBlock!()
        }
        break
      }
    }
    self.disappear()

  }

  private func disappear() {
    UIView.animate(withDuration: 0.2, animations: {
      self.alpha = 0
    }) { (finished) in
      self.removeFromSuperview()
    }
  }

  private func layoutLabel(longPressLocation: CGPoint) {
    let x: CGFloat = center.x - longPressLocation.x
    let y: CGFloat = center.y - longPressLocation.y
    let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    var lableOrigin = CGPoint.zero
    if x >= 0 {
      lableOrigin.x = screenWidth / 2.0 + 25.0
    }
    else {
      lableOrigin.x = 25.0
    }
    if y >= 0 {
      lableOrigin.y = longPressLocation.y + 150.0 - 44.0
    }
    else {
      lableOrigin.y = longPressLocation.y - 150.0
    }
    let labelFrame = CGRect(x: lableOrigin.x, y: lableOrigin.y, width: 300.0, height: 70.0)
    titleLabel.frame = labelFrame // frame

    // Font
    titleLabel.font = UIFont(name: "AvenirNext-BoldItalic", size: 30)
    titleLabel.textColor = UIColor.black
    self.addSubview(titleLabel)
  }

}
