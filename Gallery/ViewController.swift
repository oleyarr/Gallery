
//  ViewController.swift
//  Gallery
//
//  Created by Володя on 08.07.2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadPictureButton: UIButton!
    @IBOutlet weak var testSizeView: UIView!
    
    var userDefaults = UserDefaults.standard
    var picturesInfoArray: [PicturesInfoArray] = []
    lazy var addImageViewController = AddImageNSObject(viewController: self, customCollectionViewCell: CustomCollectionViewCell())
    var selectedIndexPath: IndexPath?
    private var fileManager = FileManager.default
    private lazy var cacheFolderURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    private lazy var savedImagesFolderURL = cacheFolderURL.appendingPathComponent("Images")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? fileManager.createDirectory(at: savedImagesFolderURL, withIntermediateDirectories: true, attributes: [ : ])
        picturesInfoArray = getSavedPictures()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @IBAction func loadPictureButtonPressed(_ sender: Any) {
        addImageViewController.addImage(completion: {
         print("проба completion")
        })
    }
    
    func getSavedPictures() -> [PicturesInfoArray] {
        // достаем информацию о картинках: путь к картинкам, кол-во лайков, комменты и прочее
        if let dataKey = userDefaults.value(forKey: "Gallery") as? Data {
            let decoder = JSONDecoder()
            do {
            let getData = try decoder.decode([PicturesInfoArray].self, from: dataKey)
                return getData
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return []
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesInfoArray.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as? CustomCollectionViewCell else { return UICollectionViewCell() }
        if !(picturesInfoArray.count == 1 && picturesInfoArray[0].imageName == "default_image") {
            let imageFileName = picturesInfoArray[indexPath.item].imageName
            let imageFileURL = savedImagesFolderURL.appendingPathComponent(imageFileName)
            do {
                let imageData = try Data(contentsOf: imageFileURL)
                let image = UIImage(data: imageData)
                cell.imageViewInCell.image = image
            } catch {
                print("error= ",error.localizedDescription)
            }
        } else {
            cell.imageViewInCell.image = UIImage(named: "default_image")
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPath == nil {
            selectedIndexPath = indexPath   
            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.scrollDirection = .horizontal
                collectionView.isPagingEnabled = true
            }
        } else {
            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.scrollDirection = .vertical
                collectionView.isPagingEnabled = false
                selectedIndexPath = nil
            }
        }
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectedIndexPath == nil {
            return CGSize(width: collectionView.frame.size.width / 2 - 20, height: collectionView.frame.size.height / 4 - 40)
        } else {
            return collectionView.frame.size
        }
    }
}
