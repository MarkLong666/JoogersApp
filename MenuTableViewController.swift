//
//  MenuTableViewController.swift
//  joggers
//
//  Created by Long Baolin on 16/3/16.
//  Copyright © 2016年 Lintasty. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    //用于配置Cell的图标和文字的属性
    private var cellTitles = ["RUNNER", "New run", "History"]
    private var cellFontNames = ["AvenirNextCondensed-italic", "Futura-Medium", "Futura-Medium"]
    private var cellFontSize: [CGFloat] = [40, 22, 22]
    private var imageNames = ["nil", "running_man", "running_history"]
    private var highlightImageNames = ["nil", "running_man_highlight", "running_history_highlight"]
    //两个可选的table row的image icon
    private var firstImageView: UIImageView!
    private var seconImageView: UIImageView!
    
    //将status bar设置为LightContent因为这个视图是全黑的
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

   
    
    //MARK; - UITabelViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        //配置Cell的图标和文字
        if indexPath.row != 0{
            
            if indexPath.row == 1{
                firstImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0 , y: 0 + cell.layer.bounds.height/1.5 ), size: CGSize(width: cell.layer.bounds.height/2, height: cell.layer.bounds.height/2)))
                firstImageView.image = UIImage(named: imageNames[indexPath.row])
                cell.addSubview(firstImageView)
            }else if indexPath.row == 2{
                seconImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0 , y: 0 + cell.layer.bounds.height/1.5 ), size: CGSize(width: cell.layer.bounds.height/2, height: cell.layer.bounds.height/2)))
                seconImageView.image = UIImage(named: imageNames[indexPath.row])
                cell.addSubview(seconImageView)
            }
            
            
            }
        
        cell.textLabel?.text = cellTitles[indexPath.row]
        if let font = UIFont(name: cellFontNames[indexPath.row], size: cellFontSize[indexPath.row]){
            cell.textLabel?.font = font
            cell.textLabel?.textColor = UIColor.lightGrayColor()
        }
        
        //将Cell的背景色设置为透明，是其呈黑色
        cell.backgroundColor = UIColor.clearColor()
        
        //自定义选中后row所显示的颜色，这里设置成了不显示
        let selectedBackgroundView = UIView(frame: cell.frame)
        selectedBackgroundView.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView = selectedBackgroundView
        
        return cell
    }

    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        //创建一个褐色字体的Label覆盖原有Label，使得选中后row的字体颜色呈褐色
        let highlightedTextLabel = UILabel(frame: (cell?.textLabel?.bounds)!)
        highlightedTextLabel.font = cell?.textLabel?.font
        highlightedTextLabel.textColor = MySpecialColors.starbucksBrown
        highlightedTextLabel.text = cell?.textLabel?.text
        cell?.textLabel?.addSubview(highlightedTextLabel)
        
        //创建一个褐色图标的imageView覆盖原有图标，使得选中后row中的图标呈现褐色
        let highlightedIconImageView = UIImageView(frame: indexPath.row == 1 ? firstImageView.frame : seconImageView.frame)
        highlightedIconImageView.image = UIImage(named: highlightImageNames[indexPath.row])
        cell?.addSubview(highlightedIconImageView)
        
        //在一秒后将覆盖在上面的图标移除
        delay(seconds: 1) { _ in
            highlightedTextLabel.removeFromSuperview()
            highlightedIconImageView.removeFromSuperview()
            
        }
    }
    
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if indexPath.row == 0{
            
            return nil
        }else if indexPath.row == 1{
            
            performSegueWithIdentifier("gotoNewRunView", sender: nil)
            return indexPath
        }else{
            
            performSegueWithIdentifier("gotoHistoryView", sender: nil)
            return indexPath
        }
    }
    
    
}
