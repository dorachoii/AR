//
//  ARRoomContainer.swift
//  Naevis
//
//  Created by dora on 12/11/24.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARRoomView: View{
    @State private var isLoading = true
    
    var body: some View{
        ZStack{
            ZStack{
                ARRoomContainer(isLoading: $isLoading)
                    .ignoresSafeArea()
                VStack{
                    Spacer()
                        .frame(height: 100)
                    VStack{
                        Text("제스처를 통해 방을 둘러보세요!")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    }.padding(15)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                        )
                        .cornerRadius(10)
                        .padding()
                        .opacity(isLoading ? 0 : 1)
                    Spacer()
                }
            }
            
            if isLoading{
                ProgressView("나이비스는 방 정리중!")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
            }
        }
        
    }
}
struct ARRoomContainer: UIViewRepresentable {
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> some UIView {
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.black)
        
        let anchor = AnchorEntity(world: [0,-1.5,0])
        
        Task{
            do{
                //MARK: Room
                let roomEntity = try await ModelEntity(named: "Room")
                roomEntity.generateCollisionShapes(recursive: true)
                arView.installGestures([.scale, .rotation],for: roomEntity)
                
                let naevis = try await ModelEntity(named: "naevisHello2")
                naevis.scale = naevis.scale * 2
                
                let rotationZ = simd_quatf(angle: .pi / 2, axis: [0, 0, 1])
                let rotationZ2 = simd_quatf(angle:-.pi / 2, axis: [0, 0, 1])
                
                // 회전을 결합하여 적용
                naevis.orientation = simd_mul(rotationZ2, rotationZ)
                
                naevis.position.x += 0.9
                
                print("가능한 애니메이션은 \(naevis.availableAnimations.count)")
                
                if let animation = naevis.availableAnimations.first {
                    naevis.playAnimation(animation.repeat(), transitionDuration: 0.5, startsPaused: false)
                }
                
                roomEntity.addChild(naevis)
                context.coordinator.roomEntity = roomEntity
                anchor.addChild(roomEntity)
                
                arView.scene.addAnchor(anchor)
                
                //MARK: Camera
                let camera = PerspectiveCamera()
                camera.position = [0, 5, 7]
                
                let cameraAnchor = AnchorEntity(world: [0,0,0])
                cameraAnchor.addChild(camera)
                
                camera.look(at: roomEntity.position, from: camera.position, relativeTo: nil)
                arView.scene.addAnchor(cameraAnchor)
                
                context.coordinator.cancellable = arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
                    
                    // MARK: 모델 사이즈 Clamp
                    context.coordinator.clampRoomSize()
                } as? AnyCancellable
                
                DispatchQueue.main.async {
                    isLoading = false
                }
            } catch{
                print("Error loading model: \(error)")
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
        return arView
        
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator_room {
        return Coordinator_room()
    }
}

class Coordinator_room: NSObject, ObservableObject {
    
    var roomEntity : ModelEntity?
    var cancellable: AnyCancellable?
    
    // MARK: 크기 clamp
    func clampRoomSize() {
        guard let room = roomEntity else { return }
        
        let minScale: Float = 0.5
        let maxScale: Float = 2.0
        let currentScale = room.scale(relativeTo: nil).x
        
        if currentScale < minScale {
            let clampedScale = SIMD3<Float>(repeating: minScale)
            room.scale = clampedScale
        } else if currentScale > maxScale {
            let clampedScale = SIMD3<Float>(repeating: maxScale)
            room.scale = clampedScale
        }
    }
}


