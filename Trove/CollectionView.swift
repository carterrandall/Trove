//
//  CollectionView.swift
//  Trove
//
//  Created by Carter Randall on 2020-05-31.
//  Copyright © 2020 Carter Randall. All rights reserved.
//

import UIKit
import ARKit

protocol CollectionViewDelegate {
    func didSelectMap(map: ARWorldMap)
}

class CollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    fileprivate let cellId = "cellId"
    
    var delegate: CollectionViewDelegate?
    
    var maps = [Map]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var selectedIndex = 0
    var isInitialScroll = true
    
    lazy var collectionView: UICollectionView = {
        
        let layout = ZoomAndSnapFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.decelerationRate = .fast
        return cv
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(PreviewCell.self, forCellWithReuseIdentifier: cellId)
        addSubview(collectionView)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //delegate and data source methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PreviewCell

        cell.layer.cornerRadius = 5
        cell.backgroundColor = .none
        cell.imageView.image = maps[indexPath.item].snapshot
        
        if selectedIndex == indexPath.item {
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.mainGold().cgColor
        } else {
            cell.layer.borderWidth = 0
        }
        
        if selectedIndex == 0 && indexPath.item == 0 && isInitialScroll {
            if let wm = maps[indexPath.item].worldMap {
                delegate?.didSelectMap(map: wm)
                isInitialScroll = false
            }
        }
    
        
        cell.setShadow(offset: CGSize(width: 0, height: 4), opacity: 0.3, radius: 5, color: UIColor.black)
        return cell
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isInitialScroll = false
        let x = scrollView.contentOffset.x
        let item = collectionView.indexPathForItem(at: CGPoint(x: frame.width / 2 + x, y: frame.height / 2))
        guard let i = item?.item else { return }
        callDelegate(index: i)
        self.selectedIndex = i
        self.collectionView.reloadData()
    }
    
    func callDelegate(index: Int) {
        guard let wm = maps[index].worldMap else { return }
        delegate?.didSelectMap(map: wm)
    }
    

}
