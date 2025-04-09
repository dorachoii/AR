//
//  ContentView.swift
//  Naevis
//
//  Created by dora on 11/17/24.
//

import SwiftUI
import RealityKit
import ARKit

// TODO: 충돌 체크 후, 아이템 없애기, 하트 효과 나오기, 슬라이더 채워지기

enum ViewType: String, CaseIterable {
    case arView
    case roomView
}
//
//struct ContentView: View {
//    @State private var selectedView: ViewType = .arView
//    @StateObject var coordinator = Coordinator()
//
//    var body: some View {
//        ZStack {
//            // MARK: 선택뷰 표시
//            if selectedView == .arView {
//                ARNaevisView(coordinator: coordinator)
//            } else {
//                ARRoomView()
//            }
//
//            // MARK: toolbar대신 ZStack으로!
//            VStack {
//                Spacer()
//                    .frame(height: 50)
//                HStack {
//                    //MARK: reset
//                    Button(action: {
//                        print("Reset button pressed")
//                        coordinator.resetWorld()
//                    }) {
//                        HStack {
//                            Image(systemName: "arrow.trianglehead.clockwise")
//                                .foregroundColor(.black)
//                        }
//                        .padding(5)
//                    }
//                    .background(.secondary)
//                    .opacity(0.6)
//                    .cornerRadius(5)
//
//                    Spacer()
//
//                    //MARK: reset
//                    Picker("View Type", selection: $selectedView) {
//                        Image(systemName: "gamecontroller.fill")
//                            .foregroundStyle(.secondary)
//                            .tag(ViewType.arView)
//
//                        Image(systemName: "house.fill")
//                            .foregroundStyle(.secondary)
//                            .tag(ViewType.roomView)
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    .frame(width: 150)
//                }
//                .padding()
//
//                Spacer() // 나머지 공간 채우기
//            }
//        }
//        .ignoresSafeArea()
//    }
//}

struct ContentView: View {
    @State private var selectedView: ViewType = .arView
    @StateObject var coordinator = Coordinator()
    @State var sliderValue:Float = 0.0
    
    var body: some View {
        ZStack {
            // MARK: 선택뷰 표시
            if selectedView == .arView {
                ARNaevisView(coordinator: coordinator, sliderValue: $sliderValue)
            } else {
                ARRoomView()
            }
            
            // MARK: toolbar대신 ZStack으로!
            VStack {
                Spacer()
                    .frame(height: 50)
                HStack {
                    //MARK: reset
                    Button(action: {
                        print("Reset button pressed")
                        coordinator.resetWorld()
                    }) {
                        HStack {
                            Image(systemName: "arrow.trianglehead.clockwise")
                                .foregroundColor(.black)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                        
                                )
                                
                        }
                        .padding(5)
                    }
                    //                    .background(.secondary)
                    //                    .opacity(0.6)
                    //                    .cornerRadius(5)
                    .opacity(selectedView == .arView ? 1 : 0)
                    
                    Spacer()
                    
                    //MARK: reset
                    Picker("View Type", selection: $selectedView) {
                        Image(systemName: "gamecontroller.fill")
                            .foregroundStyle(.secondary)
                            .tag(ViewType.arView)
                        
                        Image(systemName: "house.fill")
                            .foregroundStyle(.secondary)
                            .tag(ViewType.roomView)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                }
                .padding()
                
                Spacer() // 나머지 공간 채우기
            }
        }
        .ignoresSafeArea()
    }
}





#Preview {
    ContentView()
}
