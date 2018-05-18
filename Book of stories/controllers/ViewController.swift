//
//  ViewController.swift
//  Book of stories
//
//  Created by Alex Odintsov on 06.05.2018.
//  Copyright © 2018 Alex Odintsov. All rights reserved.
//

import UIKit
import Photos
import os.log

var dateString = ""


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
    //MARK: Properties
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var Calendar: UICollectionView!
    let months = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    let days = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    var currentMonth = String()
    var dayCounter = 0
    
    var stories = [Story]()
    var cellsArray: [UICollectionViewCell] = []
    var hightlight = -1
    var selectedItem: IndexPath?
    
    //MARK: Properties of images collection
    @IBOutlet weak var Images: UICollectionView!
    
    var imagesArray: [UIImage] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentMonth = months[month]
        monthLabel.text = "\(currentMonth) \(year)"
        
        if weekday == 0 {
            weekday = 7
        }
        gerStartDateDayPosition()
        
        Images.delegate = self
        Images.dataSource = self
        
        
        if let savedStories = loadStories() {
            stories += savedStories
        }
        else {
            loadSampleStories()
        }

        imagesArray = loadPreviewPhotos()

    }
    
    //MARK: Action
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
            switch segue.identifier ?? "" {
            case "addItem":
                print("Pressed add item button")
            case "dayDetails":
                guard let storyDayDetailViewController = segue.destination as? PickedDateViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                guard let selectedStoryCell = sender as? DataCollectionViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                guard let indexPath = Calendar.indexPath(for: selectedStoryCell) else {
                    fatalError("The selected cell is not being displayed by the collection")
                }
                let selectedStory = findStoryByDay(stories: stories, indexPath: indexPath)
                storyDayDetailViewController.story = selectedStory
                
                print("Pressed day details")
            case "imageDetails":
                guard let storyImageDetailViewController = segue.destination as? PickedDateViewController else {
                    fatalError()
                }
                guard let selectedImageStoryCell = sender as? ImageCollectionViewCell else {
                    fatalError()
                }
                guard let indexImagePath = Images.indexPath(for: selectedImageStoryCell) else {
                    fatalError()
                }
                let selectedImageStory = findStoryByImage(stories: stories, indexPath: indexImagePath)
                storyImageDetailViewController.story = selectedImageStory
                
                print("Pressed image details")
            default:
                fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
                    
        }
    }
    
    @IBAction func unwindToMainView(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? PickedDateViewController, let story = sourceViewController.story {
            var finded: Bool = false
            if !stories.isEmpty{
                //апдейт существующего стори, если есть
                for item in stories {
                    if item.date == story.date {
                        item.photo = story.photo
                        item.text = story.text
                        item.name = story.name
                        finded = true
                    } else if !finded {
                        stories.append(story)
                        self.Images.reloadData()
                    }
                }
            } else {
                //добавить новый стори
                let newIndexPath = IndexPath(row: stories.count, section: 0)
                stories.append(story)
                
                if stories.count == 1 {
                    self.Images.reloadData()
                } else {
                self.Images.insertItems(at: [newIndexPath])
                self.Images.reloadData()
                }
            }
            imagesArray = loadPreviewPhotos()
            saveStrories()
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        hightlight = -1
        switch currentMonth {
        case "Январь":
            month = 11
            year -= 1
            direction = -1
            
            gerStartDateDayPosition()
            
            //TODO: сделать для весокосного года
            
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth) \(year)"
            moveAnimatiosBack(label: monthLabel)
            Calendar.reloadData()
        default:
            month -= 1
            direction = -1
            
            gerStartDateDayPosition()
            
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth) \(year)"
            moveAnimatiosBack(label: monthLabel)
            Calendar.reloadData()
        }
    }
    @IBAction func nextButton(_ sender: UIButton) {
        hightlight = -1
        switch currentMonth {
        case "Декабрь":
            month = 0
            year += 1
            direction = 1

            //TODO: сделать для весокосного года
            
            gerStartDateDayPosition()
            
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth)\(year)"
            moveAnimationsNext(label: monthLabel)
            Calendar.reloadData()
        default:
            direction = 1
            
            gerStartDateDayPosition()
            
            month += 1
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth)\(year)"
            moveAnimationsNext(label: monthLabel)
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
        switch collectionView {
        case self.Calendar:
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
        case self.Images:
            return imagesArray.count
        default:
            fatalError("No one collection view is not presented at View Controller")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.Calendar{ //для календаря
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
            if currentMonth == months[calendar.component(.month, from: date) - 1] && year == calendar.component(.year, from: date) && day == indexPath.row {
                cell.backgroundColor = UIColor.darkGray
            }
            cellsArray.append(cell)
            
            return cell
        } else { //для фото
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Images", for: indexPath) as! ImageCollectionViewCell
            
            cell.image.image = imagesArray[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //для календаря
        if collectionView == self.Calendar {
        cell.alpha = 0
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        
        for x in cellsArray {
            let cell: UICollectionViewCell = x
            UIView.animate(withDuration: 1, delay: 0.01 * Double(indexPath.row), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                cell.alpha = 1
                cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
            })
        }
        
        //выбранный день
        if hightlight == indexPath.row {
            cell.backgroundColor = UIColor.red
        }
        }//else { для фото
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        dateString = "\(indexPath.row - positionIndex + 1) \(currentMonth) \(year)"
            
        hightlight = indexPath.row
        selectedItem = indexPath
        collectionView.reloadData()
    }
    
    
    //MARK: Private methods
    //TODO: отрефакторить
    private func saveStrories() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(stories, toFile: Story.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Succesful saved stories", log: OSLog.default, type: .debug)
        } else {
            os_log("Faild to save stories", log: OSLog.default, type: .error)
        }
    }
    private func loadStories() -> [Story]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Story.ArchiveURL.path) as? [Story]
    }
    private func loadPreviewPhotos() -> [UIImage] {
        var previewImages: [UIImage] = []
//        if let stories = loadStories() {
            for story in stories {
                if let images = story.photo {
                    if let image = images.reversed().first {
                        //TODO: сделать картинку, если нет фото для текущей даты
                        previewImages.append(image)
                    }
                }
            }
//        }
        return previewImages
    }
    private func loadSampleStories() {
        //TODO: написать загрузчик сторисов по умолчанию
    }
    private func findStoryByDay(stories: [Story], indexPath: IndexPath) -> Story{
        var story: Story?

        for item in stories {
            if item.date == "\(indexPath.row - positionIndex + 1) \(currentMonth) \(year)" {
                story = item
            }
        }
        if story == nil {
            story = Story(name: "новое", date: "\(indexPath.row - positionIndex + 1) \(currentMonth) \(year)", photo: [UIImage(named: "defaultPhoto")!], text: "")
        }
        return story!
    }
    private func findStoryByImage(stories: [Story], indexPath: IndexPath) -> Story{
        var story: Story?

        guard let cell = Images.cellForItem(at: indexPath) as? ImageCollectionViewCell else {
            fatalError("Images not contains item at \(indexPath)")
        }
        for item in stories {
            if let photos = item.photo, let image = cell.image.image {
                if photos.contains(image) {
                    story = item
                }
            }
        }
        if story == nil {
            story = Story(name: "новое", date: "\(indexPath.row - positionIndex + 1) \(currentMonth) \(year)", photo: [UIImage(named: "defaultPhoto")!], text: "")
        }
        return story!
    }
}
