//
//  UICollectionViewExtension.swift
//  task
//
//  Created by Osama Walid on 08/10/2023.
//


import UIKit

extension UICollectionView {
    
    func register<Cell: UICollectionViewCell>(cellClass: Cell.Type) {
        self.register(UINib(nibName: String(describing: Cell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: Cell.self))
    }
    
    func dequeueReusableCell<Cell: UICollectionViewCell>(withClass name: Cell.Type, for indexPath: IndexPath) -> Cell {
        let identifier = String(describing: name)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError("Couldn't find UICollectionViewCell for \(identifier), make sure the cell is registered with UICollectionView")
        }
        
        return cell
    }
    
}


extension UITableView {
    
    func register<Cell: UITableViewCell>(cellClass: Cell.Type) {        
        self.register(UINib(nibName: String(describing: Cell.self), bundle: nil), forCellReuseIdentifier: String(describing: Cell.self))
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>(withClass name: Cell.Type, for indexPath: IndexPath) -> Cell {
        let identifier = String(describing: name)
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError("Couldn't find UICollectionViewCell for \(identifier), make sure the cell is registered with UICollectionView")
        }
        
        return cell
    }
    
}
