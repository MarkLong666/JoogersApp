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
    fileprivate var cellTitles = ["RUNNER", "New run", "History"]
    fileprivate var cellFontNames = ["AvenirNextCondensed-italic", "Futura-Medium", "Futura-Medium"]
    fileprivate var cellFontSize: [CGFloat] = [40, 22, 22]
    fileprivate var imageNames = ["nil", "running_man", "running_history"]
    fileprivate var highlightImageNames = ["nil", "running_man_highlight", "running_history_highlight"]
    //两个可选的table row的image icon
    fileprivate var firstImageView: UIImageView!
    fileprivate var seconImageView: UIImageView!
    
    //将status bar设置为LightContent因为这个视图是全黑的
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

   
    
    //MARK; - UITabelViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        //配置Cell的图标和文字
        if (indexPath as NSIndexPath).row != 0{
            
            if (indexPath as NSIndexPath).row == 1{
                firstImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0 , y: 0 + cell.layer.bounds.height/1.5 ), size: CGSize(width: cell.layer.bounds.height/2, height: cell.layer.bounds.height/2)))
                firstImageView.image = UIImage(named: imageNames[(indexPath as NSIndexPath).row])
                cell.addSubview(firstImageView)
            }else if (indexPath as NSIndexPath).row == 2{
                seconImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0 , y: 0 + cell.layer.bounds.height/1.5 ), size: CGSize(width: cell.layer.bounds.height/2, height: cell.layer.bounds.height/2)))
                seconImageView.image = UIImage(named: imageNames[(indexPath as NSIndexPath).row])
                cell.addSubview(seconImageView)
            }
            
            
            }
        
        cell.textLabel?.text = cellTitles[(indexPath as NSIndexPath).row]
        if let font = UIFont(name: cellFontNames[(indexPath as NSIndexPath).row], size: cellFontSize[(indexPath as NSIndexPath).row]){
            cell.textLabel?.font = font
            cell.textLabel?.textColor = UIColor.lightGray
        }
        
        //将Cell的背景色设置为透明，是其呈黑色
        cell.backgroundColor = UIColor.clear
        
        //自定义选中后row所显示的颜色，这里设置成了不显示
        let selectedBackgroundView = UIView(frame: cell.frame)
        selectedBackgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = selectedBackgroundView
        
        return cell
    }

    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        //创建一个褐色字体的Label覆盖原有Label，使得选中后row的字体颜色呈褐色
        let highlightedTextLabel = UILabel(frame: (cell?.textLabel?.bounds)!)
        highlightedTextLabel.font = cell?.textLabel?.font
        highlightedTextLabel.textColor = MySpecialColors.starbucksBrown
        highlightedTextLabel.text = cell?.textLabel?.text
        cell?.textLabel?.addSubview(highlightedTextLabel)
        
        //创建一个褐色图标的imageView覆盖原有图标，使得选中后row中的图标呈现褐色
        let highlightedIconImageView = UIImageView(frame: (indexPath as NSIndexPath).row == 1 ? firstImageView.frame : seconImageView.frame)
        highlightedIconImageView.image = UIImage(named: highlightImageNames[(indexPath as NSIndexPath).row])
        cell?.addSubview(highlightedIconImageView)
        
        //在一秒后将覆盖在上面的图标移除
        delay(seconds: 1) {
            highlightedTextLabel.removeFromSuperview()
            highlightedIconImageView.removeFromSuperview()
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if (indexPath as NSIndexPath).row == 0{
            
            return nil
        }else if (indexPath as NSIndexPath).row == 1{
            
            performSegue(withIdentifier: "gotoNewRunView", sender: nil)
            return indexPath
        }else{
            
            performSegue(withIdentifier: "gotoHistoryView", sender: nil)
            return indexPath
        }
    }
    
    
}
