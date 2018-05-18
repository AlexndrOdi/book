//
//  Story.swift
//  Book of stories
//
//  Created by Alex Odintsov on 11.05.2018.
//  Copyright © 2018 Alex Odintsov. All rights reserved.
//

import UIKit
import os.log

class Story: NSObject, NSCoding {
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let date = "date"
        static let photo = "photo"
        static let text = "text"
    }
    
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("stories")
    
    //MARK: Properties
    var name: String = ""
    var date: String = ""
    var photo: [UIImage]?
    var text: String?
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(text, forKey: PropertyKey.text)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Story object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let date = aDecoder.decodeObject(forKey: PropertyKey.date) as? String else {
            os_log("Unable to decode the date for a Story object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? [UIImage] else {
            os_log("Unable to decode the photo for a Story object.", log: OSLog.default, type: .debug)
            return nil
        }
        let text = aDecoder.decodeObject(forKey: PropertyKey.text) as? String
        
        self.init(name: name, date: date, photo: photo, text: text)
    }
    
    //MARK: Initialization
    init?(name: String, date: String, photo: [UIImage]?, text: String?) {
        
        guard !name.isEmpty else {
            os_log("Unable to init the name for a Story object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard !date.isEmpty else {
            os_log("Unable to init the name for a Story object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.name = name
        self.date = date
        self.photo = photo
        self.text = text
    }
}
