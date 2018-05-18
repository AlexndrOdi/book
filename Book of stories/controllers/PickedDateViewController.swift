//
//  PickedDateViewController.swift
//  Book of stories
//
//  Created by Alex Odintsov on 09.05.2018.
//  Copyright © 2018 Alex Odintsov. All rights reserved.
//

import UIKit

class PickedDateViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet var pickedImageView: UIView!
    @IBOutlet weak var selectedImage: UIImageView!
    var effect: UIVisualEffect!
    var selectedRow = -1
    var story: Story?
    
    var imagesOfPickedDay: [UIImage] = []
    
    
    //MARK: Navigations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
               
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            print("The save button was not pressed, cancelling")
            return
        }
        let name = "в разработке пока что"
        let date = dateString
        let photo = imagesOfPickedDay
        let text = textView.text
        
        story = Story(name: name, date: date, photo: photo, text: text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        imageCollection.delegate = self
        imageCollection.dataSource = self
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        textView.backgroundColor = UIColor(red: 250/255, green: 248/255, blue: 219/255, alpha: 1)

        if let story = story {
            navigationItem.title = story.date
            textView.text = story.text
            imagesOfPickedDay = story.photo!
        }
    }
    
    //MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        let isPresentingInAddStoryMode = presentingViewController is UINavigationController
        if isPresentingInAddStoryMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The PickedDateViewController is not inside a navigation controller.")
        }
    }
  
    //MARK: Selected Image View with tap gesture
    @IBAction func closeSelectedImage(_ sender: UITapGestureRecognizer) {
        pickedImageView.center = self.view.center
        animateSelectedImageOut(view: pickedImageView, navigationController: navigationController)
    }
    
    //MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesOfPickedDay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesOfPickedDay", for: indexPath) as! ImagePickedDayCollectionViewCell
        
        cell.imageOfPickedDay.image = imagesOfPickedDay[indexPath.row]
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        textView.resignFirstResponder()
        
        if indexPath.row > 0 {
            self.view.addSubview(pickedImageView)
            selectedImage.image = imagesOfPickedDay[indexPath.row]
            pickedImageView.center = self.view.center
            animateSelectedImageIn(view: pickedImageView, navigationController: navigationController)
        } else {
            let imagePickerController = UIImagePickerController()
            //TODO: добавить возможность снимать с камеры
            //пока что только из фото галереи
            selectedRow = indexPath.row //запомнил нажатый элемент
        
            imagePickerController.sourceType = .photoLibrary
        
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    //MARK: Text View
    func textViewDidBeginEditing(_ textView: UITextView) {
        imageCollection.isUserInteractionEnabled = false
        textView.backgroundColor = UIColor.white
        animateBlurIn(visualEffectView: visualEffectView, effect: effect)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.backgroundColor = UIColor(red: 250/255, green: 248/255, blue: 219/255, alpha: 1)
        animateBlurOut(visualEffectView: visualEffectView, effect: effect)
        textView.resignFirstResponder()
        imageCollection.isUserInteractionEnabled = true
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    //MARK: Image Picker Actions
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        dismiss(animated: true, completion: nil)
        imagesOfPickedDay.append(selectedImage)
        imageCollection.reloadData()
    }
    
    //MARK: Private methods
    private func loadStory(story: Story) {
        textView.text = story.text
        imagesOfPickedDay = story.photo!
    }
    //TODO: отрефакторить
    private func saveStory(story: Story) {
        story.text = textView.text
        story.photo = imagesOfPickedDay
        story.name = "в разработке"
    }
    private func findPickedStory(stories: [Story]) -> Story? {
        //TODO: допилить, чтобы была возможность по дате искать нормально
        var story: Story?
        for item in stories {
            if item.date == dateString {
                story = item
            }
        }
        return story
    }
    
    
}
