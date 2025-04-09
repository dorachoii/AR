//
//  ItemModel.swift
//  Naevis
//
//  Created by dora on 11/17/24.
//

import Foundation

//
//  ItemAndInventoryModel.swift
//  Naeilmalhalgang
//
//  Created by kdk on 11/1/24.
//

import SwiftUI


// MARK: struct - 리워드 아이템
struct Item {
    var itemName: String            // 아이템 이름
    var modelName: String           // 아이템 png명
}

// MARK: class - 인벤토리 관련
class Inventory: ObservableObject {
    
    static let shared = Inventory()
    
    @Published var itemArray: [Item] = [
        Item(itemName: "테이프", modelName: "props_tape"),
        Item(itemName: "초콜렛", modelName: "props_hotchoco"),
        Item(itemName: "인형", modelName: "props_bear"),
        Item(itemName: "스노우볼", modelName: "props_snowball"),
    ]
    

}
