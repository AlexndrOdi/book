//
//  ViewController.swift
//  Book of stories
//
//  Created by Alex Odintsov on 06.05.2018.
//  Copyright © 2018 Alex Odintsov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
    //MARK: Properties
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var Calendar: UICollectionView!
    let months = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    let days = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    var currentMonth = String()
    var dayCounter = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentMonth = months[month]
        monthLabel.text = "\(currentMonth)\(year)"
        
        if weekday == 0 {
            weekday = 7
        }
        gerStartDateDayPosition()
    }
    
    //MARK: Action
    @IBAction func backButton(_ sender: UIButton) {
        switch currentMonth {
        case "Январь":
            month = 11
            year -= 1
            direction = -1
            
            gerStartDateDayPosition()
            
            //TODO: сделать для весокосного года
            
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth)\(year)"
            Calendar.reloadData()
        default:
            month -= 1
            direction = -1
            
            gerStartDateDayPosition()
            
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth)\(year)"
            Calendar.reloadData()
        }
    }
    @IBAction func nextButton(_ sender: UIButton) {
        switch currentMonth {
        case "Декабрь":
            month = 0
            year += 1
            direction = 1
            
            //TODO: сделать для весокосного года 
            
            gerStartDateDayPosition()
            
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth)\(year)"
            Calendar.reloadData()
        default:
            direction = 1
            
            gerStartDateDayPosition()
            
            month += 1
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth)\(year)"
            Calendar.reloadData()
        }
    }
    
    func gerStartDateDayPosition() { //возвращает количество пустых боксов
        switch direction {
        case 0:
            numbersOfEmptyBox = weekday
            dayCounter = day

            while dayCounter > 0 {
                dayCounter -= 1
                numbersOfEmptyBox -= 1
                if numbersOfEmptyBox == 0 {
                    numbersOfEmptyBox = 7
                }
            }
            if numbersOfEmptyBox == 7 {
                numbersOfEmptyBox = 0
            }
            
            positionIndex = numbersOfEmptyBox
        case 1...:
            nextNumberOfEmptyBox = (positionIndex + daysInMonth[month])%7
            positionIndex = nextNumberOfEmptyBox
        case -1:
            previousNumberOfEmptyBox = (7 - (daysInMonth[month] - positionIndex)%7)
            if (previousNumberOfEmptyBox == 7){
                previousNumberOfEmptyBox = 0
            }
            positionIndex = previousNumberOfEmptyBox
        default:
            fatalError("Direction not equals -1, 0 or 1. Direction: \(direction)")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Возвращает количество секций в коллекции (дней в текущем месяце) + количество пустых боксов
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch direction {
        case 0:
            return daysInMonth[month] + numbersOfEmptyBox
        case 1...:
            return daysInMonth[month] + nextNumberOfEmptyBox
        case -1:
            return daysInMonth[month] + previousNumberOfEmptyBox
        default:
            fatalError("Direction in collection view out of range. Direction: \(direction)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Calendar", for: indexPath) as! DataCollectionViewCell
        cell.backgroundColor = UIColor.clear
        
        if cell.isHidden {
            cell.isHidden = false
        }
        
        switch direction {
        case 0:
            cell.dateLabel.text = "\(indexPath.row + 1 - numbersOfEmptyBox)"
        case 1...:
            cell.dateLabel.text = "\(indexPath.row + 1 - nextNumberOfEmptyBox)"
        case -1:
            cell.dateLabel.text = "\(indexPath.row + 1 - previousNumberOfEmptyBox)"
        default:
            fatalError("Direction in cell out of range. Direction: \(direction)")
        }
        
        if Int(cell.dateLabel.text!)! < 1 {
            cell.isHidden = true
        }
        
        //окрашиваем выходные дни в светло серый
        switch indexPath.row {
        case 5,6,12,13,19,20,26,27,33,34:
            cell.dateLabel.textColor = UIColor.blue
        default:
            cell.dateLabel.textColor = UIColor.black
        }
        
        //окрашиваем текущий день в темно серый
        if currentMonth == months[calendar.component(.month, from: date) - 1] && year == calendar.component(.year, from: date) && day == indexPath.row + 1 {
            cell.backgroundColor = UIColor.darkGray
        }
        
        return cell
    }
}

