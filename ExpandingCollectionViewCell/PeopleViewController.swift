//
//  PeopleViewController.swift
//  ExpandingCollectionViewCell
//
//  Created by Shawn Gee on 9/28/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import SwiftUI
import UIKit

class PeopleViewController: UIViewController {
    enum Section {
        case main
    }
    
    // MARK: - Private Properties
    
    private let people: [Person] = [
        Person(name: "Shawn", age: 31, favoriteColor: "Blue", favoriteMovie: "Dinner For Schmucks"),
        Person(name: "Bob", age: 54, favoriteColor: "Red", favoriteMovie: "Saving Private Ryan"),
        Person(name: "Susan", age: 23, favoriteColor: "Teal", favoriteMovie: "The Lion King"),
    ]
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private var dataSource: UICollectionViewDiffableDataSource<Section, Person>?
    
    private let padding: CGFloat = 12
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        setUpDataSource()
        collectionView.delegate = self
    }
    
    // MARK: - Private Methods
    
    private func createLayout() -> UICollectionViewLayout {
        // The item and group will share this size to allow for automatic sizing of the cell's height
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .estimated(50))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        section.contentInsets = .init(top: padding, leading: padding, bottom: padding, trailing: padding)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setUpCollectionView() {
        collectionView.register(PersonCell.self, forCellWithReuseIdentifier: String(describing: PersonCell.self))
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setUpDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Person>(collectionView: collectionView) {
            (collectionView, indexPath, person) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: PersonCell.self),
                for: indexPath) as? PersonCell else {
                    fatalError("Could not cast cell as \(PersonCell.self)")
            }
            cell.person = person
            return cell
        }
        collectionView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Person>()
        snapshot.appendSections([.main])
        snapshot.appendItems(people)
        dataSource?.apply(snapshot)
    }
}

// MARK: - Collection View Delegate

extension PeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let dataSource = dataSource else { return false }
        
        // Allows for closing an already open cell
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        
        dataSource.refresh()
        
        return false // The selecting or deselecting is already performed above
    }
}

extension UICollectionViewDiffableDataSource {
    /// Reapplies the current snapshot to the data source, animating the differences.
    /// - Parameters:
    ///   - completion: A closure to be called on completion of reapplying the snapshot.
    func refresh(completion: (() -> Void)? = nil) {
        self.apply(self.snapshot(), animatingDifferences: true, completion: completion)
    }
}


// MARK: - SwiftUI Previews

struct PeopleVCWrapper: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<PeopleVCWrapper>) -> UIView {
        PeopleViewController().view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PeopleVCWrapper>) {}
}

struct PeopleVCWrapper_Previews: PreviewProvider {
    static var previews: some View {
        PeopleVCWrapper().edgesIgnoringSafeArea(.all) // remove this to respect safe area
    }
}
