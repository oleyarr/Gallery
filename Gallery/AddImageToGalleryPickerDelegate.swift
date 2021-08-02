//
//  Gallery
//
//  Created by Володя on 23.07.2021.
//

import UIKit

class AddImageToGalleryPickerDelegate: NSObject {

    private var fileManager = FileManager.default
    var completion: ((UIImage) -> ())?
    var viewController: ViewController
    
    init(viewController: ViewController) {
        self.viewController = viewController
        super.init()
    }

    func addImage(completion: @escaping (UIImage) -> ()) {
        self.completion = completion
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        viewController.present(picker, animated: true)
    }
}

extension AddImageToGalleryPickerDelegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let addedImage = info[.editedImage] as? UIImage
        {
            completion?(addedImage)
        }
        picker.dismiss(animated: true)
    }
}
