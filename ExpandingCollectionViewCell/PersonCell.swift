//
//  PersonCell.swift
//  ExpandingCollectionViewCell
//
//  Created by Shawn Gee on 9/29/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class PersonCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var person: Person? { didSet { updateContent() } }
    
    override var isSelected: Bool {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Private Properties
    
    // Labels
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        return nameLabel
    }()
    private let ageLabel = UILabel()
    private let favoriteColorLabel = UILabel()
    private let favoriteMovieLabel = UILabel()
    
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    
    // Stacks
    private lazy var rootStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [labelStack, disclosureIndicator])
        rootStack.alignment = .top
        rootStack.distribution = .fillProportionally
        return rootStack
    }()
        
    private lazy var labelStack: UIStackView = {
        let labelStack = UIStackView(arrangedSubviews: [
            nameLabel,
            ageLabel,
            favoriteColorLabel,
            favoriteMovieLabel,
        ])
        labelStack.axis = .vertical
        labelStack.spacing = padding
        return labelStack
    }()
    
    // Constraints
    private var closedConstraint: NSLayoutConstraint?
    private var openConstraint: NSLayoutConstraint?
    
    // Layout
    private let padding: CGFloat = 8
    private let cornerRadius: CGFloat = 8
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    // MARK: - Private Methods
    
    private func setUp() {
        backgroundColor = .systemGray6
        clipsToBounds = true
        layer.cornerRadius = cornerRadius

        addSubview(rootStack)
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        
        setUpConstraints()
        updateViews()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            rootStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            rootStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
        ])
        
        closedConstraint = nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                             constant: -padding)
        closedConstraint?.priority = .defaultLow
        openConstraint = favoriteMovieLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                                    constant: -padding)
        openConstraint?.priority = .defaultLow
    }

    private func updateContent() {
        guard let person = person else { return }
        nameLabel.text = person.name
        ageLabel.text = "Age: \(person.age)"
        favoriteColorLabel.text = "Favorite color: \(person.favoriteColor)"
        favoriteMovieLabel.text = "Favorite movie: \(person.favoriteMovie)"
    }
    
    private func updateViews() {
        closedConstraint?.isActive = !isSelected
        openConstraint?.isActive = isSelected
        
        UIView.animate(withDuration: 0.3) {
            // set the rotation just under 180º so that it rotates back the same way
            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
            self.disclosureIndicator.transform = self.isSelected ? upsideDown :.identity
        }
    }
}
