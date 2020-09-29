//
//  Person.swift
//  ExpandingCollectionViewCell
//
//  Created by Shawn Gee on 9/29/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import Foundation

struct Person {
    let name: String
    let age: Int
    let favoriteColor: String
    let favoriteMovie: String
    let id = UUID()
}

// Person must be hashable in order to be used as the item identifier in a diffable data source
extension Person: Hashable {
    static func == (lhs: Person, rhs: Person) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
