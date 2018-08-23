//
//  ViewController.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

struct MenuItem {
    var icon: UIImage!
    var type: MenuItemEnum
}

protocol MenuViewDelegate {
    func menuVisible(_ visible: Bool)
    func menuSelectedItem(_ item: MenuItem)
}

class MenuView: UIView {
    class func Instance() -> MenuView {
        return InstanceView() as! MenuView
    }

    var delegate: MenuViewDelegate?
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backView: UIView!
    
    var dataArray = [MenuItem]()
    var currentItem = MenuItemEnum._none
    let cellId = "MenuCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        UITableViewCell.register(tableView, cellId: cellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)

        let tapBack = UITapGestureRecognizer.init(target: self, action: #selector(swipped))
        self.backView.addGestureRecognizer(tapBack)
        
        dataArray = [
            self.addMenuItem("ico.home",      type: .home),
            self.addMenuItem("ico.incarichi", type: .inca),
            self.addMenuItem("ico.ricInc",    type: .stor),
            self.addMenuItem("ico.find",      type: .find),
            self.addMenuItem("ico.profilo",   type: .prof),
            self.addMenuItem("ico.cercando",  type: .cerc),
            self.addMenuItem("ico.news",      type: .news),
            self.addMenuItem("ico.mail",      type: .cont),
            self.addMenuItem("ico.logout",    type: .logout),
        ]
    }
    
    private func addMenuItem (_ iconName: String, type: MenuItemEnum) -> MenuItem {
        let icon = UIImage.init(named: iconName)!
        let size = 24
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        icon.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let item = MenuItem.init(icon: newImage, type: type)
        return item
    }

    @objc func swipped () {
        self.menuHide()
        self.delegate?.menuVisible(false)
    }
    
    func menuHide () {
        UIView.animate(withDuration: 0.2, animations: {
            var rect = self.frame
            rect.origin.x = -rect.size.width
            self.frame = rect
        }) { (true) in
            self.isHidden = true
        }
    }

    func menuShow () {
        self.isHidden = false
        UIView.animate(withDuration: 0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 0.6,
                                   initialSpringVelocity: 0.1,
                                   options: .curveEaseInOut,
                                   animations: {
//        UIView.animate(withDuration: 0.3) {
            var rect = self.frame
            rect.origin.x = 0
            self.frame = rect
        })
    }
}

// MARK:- UITableViewDataSource

extension MenuView: UITableViewDataSource {
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell.dequeue(tableView, indexPath, cellId: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as UITableViewCell

        let item = dataArray[indexPath.row]
        cell.imageView!.image = item.icon
        cell.textLabel?.text = item.type.rawValue
        cell.textLabel?.font = UIFont.size(14)
        if item.type == self.currentItem {
            cell.backgroundColor = UIColor.lightGray
        }
        else {
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
}

// MARK:- UITableViewDelegate

extension MenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = dataArray[indexPath.row]
        self.delegate?.menuSelectedItem(item)
    }
}
