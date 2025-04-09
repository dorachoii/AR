//
//  ExpandingInventory.swift
//  Naeilmalhalgang
//
//  Created by kdk on 10/31/24.
//

import SwiftUI

struct FloatingInventoryView: View {
    @State private var isInventoryExpanded = false
    @Binding var selectedItem: String
    @ObservedObject var coordinator: Coordinator
    @ObservedObject var inventory = Inventory.shared

    var body: some View {
        ZStack {
            ForEach(inventory.itemArray.indices, id: \.self) { index in
                createItemButton(index: index)
            }
            toggleButton
        }
    }

    @ViewBuilder
    
    private func createItemButton(index: Int) -> some View {
        let item = inventory.itemArray[index]
        
        Button(action: {
            coordinator.loadEntity(modelName: item.modelName)
        }) {
            VStack {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 69, height: 69)
                        .opacity(0.2)
                        .background(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        )


                        Image(item.modelName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    
                }
                .frame(width: 69, height: 69)
                .clipShape(Circle())

                Text(item.itemName)
                    .foregroundColor(.white)
            }
        }
        .offset(x: 0, y: isInventoryExpanded ? CGFloat(-100 * (Double(index) + 1)) : 0)
        .opacity(isInventoryExpanded ? 1 : 0)
        .animation(.easeInOut(duration: 0.4).delay(Double(index) * 0.03), value: isInventoryExpanded)
    }

    private var toggleButton: some View {
        ZStack {
            Circle()
                .fill(.secondary)
                .opacity(0.6)
                .frame(width: 69, height: 69)

            Image(systemName: isInventoryExpanded ? "arrowtriangle.down.circle.fill" : "arrowtriangle.up.circle.fill")
                .resizable()
                .frame(width: 69, height: 69)
                .foregroundStyle(Color.white)
                .opacity(0.6)
        }
        .onTapGesture {
            withAnimation {
                isInventoryExpanded.toggle()
            }
        }
    }
}


