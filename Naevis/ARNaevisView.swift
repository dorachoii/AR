//
//  ARViewContainer.swift
//  Naevis
//
//  Created by dora on 12/11/24.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

let itemGroup = CollisionGroup(rawValue: 1 << 0)
let characterGroup = CollisionGroup(rawValue: 1 << 1)

struct ARNaevisView: View {
    @ObservedObject var coordinator: Coordinator
    @Binding var sliderValue: Float
    @State private var showAlert = false
    @State private var selectedItem: String = ""
    
    var body: some View {
        ZStack {
            ARViewContainer(coordinator: coordinator, sliderValue: $sliderValue)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 100)
                
                SliderCell(sliderValue: $sliderValue)
                
                Spacer()
                
                HStack {
                    Spacer()
                    FloatingInventoryView(selectedItem: $selectedItem, coordinator: coordinator)
                        .padding()
                }
            }
            
            if showAlert {
                Color.black.opacity(0.6) // 어두운 배경
                    .ignoresSafeArea()
            }
        }
        .alert("나이비스에게 리얼월드를 알려줘서 고마워!", isPresented: $showAlert) {
            Button("다시 시작하기") {
                sliderValue = 0
                coordinator.resetWorld()
            }
        }
        .onChange(of: sliderValue) {
            if sliderValue >= 6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showAlert = true
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var coordinator: Coordinator
    @Binding var sliderValue: Float
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        coordinator.setupARView(arView)
        coordinator.sliderValueBinding = $sliderValue
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        coordinator.sliderValueBinding = $sliderValue
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

class Coordinator: NSObject, ObservableObject {
    var view: ARView?
    var naevis: ModelEntity?
    var planeAnchor: AnchorEntity?
    var decoAnchor: AnchorEntity?
    var collisionSubscriptions = [Cancellable]()
    var sliderValueBinding: Binding<Float>?
    private var processedEntities = Set<ObjectIdentifier>() // 충돌 처리한 엔티티 추적용
    
    // MARK: ARView 초기화
    func setupARView(_ arView: ARView) {
        self.view = arView
        //arView.debugOptions = [.showAnchorOrigins]
        processedEntities.removeAll() // 초기화 시 처리한 충돌 엔티티 목록도 초기화
        
        // Plane Anchor 생성
        let planeAnchor = AnchorEntity(plane: .horizontal)
        
        // naevis 모델 추가
        let naevis = try! ModelEntity.loadModel(named: "naevisDance2")
        naevis.scale /= 3
        naevis.name = "naevis"
        naevis.generateCollisionShapes(recursive: true)
        planeAnchor.addChild(naevis)
        
        // Deco Anchor 설정
        let decoAnchor = AnchorEntity()
        //decoAnchor.setPosition(SIMD3<Float>(0, 0, -0.3), relativeTo: planeAnchor)
        decoAnchor.setPosition(SIMD3<Float>(0, 0, -0.2), relativeTo: planeAnchor)
        
        self.naevis = naevis
        self.planeAnchor = planeAnchor
        self.decoAnchor = decoAnchor
        
        // 앵커 추가
        arView.scene.addAnchor(planeAnchor)
        arView.scene.addAnchor(decoAnchor)
        
        // 바닥 앵커 추가
        let floorAnchor = AnchorEntity(plane: .horizontal)
        let floor = ModelEntity(mesh: MeshResource.generateBox(size: [50, 0, 50]), materials: [OcclusionMaterial()])
        floor.generateCollisionShapes(recursive: true)
        floor.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        floorAnchor.addChild(floor)
        arView.scene.addAnchor(floorAnchor)
        
        // 충돌 이벤트 구독
        collisionSubscriptions.append(arView.scene.subscribe(to: CollisionEvents.Began.self) { [weak self] event in
            self?.handleCollision(event: event)
        })
    }
    
    // MARK: 충돌 처리
    private func handleCollision(event: CollisionEvents.Began) {
        guard let entityA = event.entityA as? ModelEntity,
              let entityB = event.entityB as? ModelEntity else { return }
        
        // hashValue를 사용해 고유한 충돌 식별자 생성
        let pairIdentifier = entityA.hashValue ^ entityB.hashValue
        guard !processedEntities.contains(ObjectIdentifier(pairIdentifier as AnyObject)) else { return }
        
        // 충돌 처리
        processedEntities.insert(ObjectIdentifier(pairIdentifier as AnyObject))
        
        print("충돌 발생: A = \(entityA.name), B = \(entityB.name)")
        if entityA.name == "naevis" && entityB.name == "deco" {
            entityB.removeFromParent()
            loadFXEntity()
        } else if entityA.name == "deco" && entityB.name == "naevis" {
            entityA.removeFromParent()
            loadFXEntity()
        }
        
        // 일정 시간 후 충돌 처리 목록에서 제거
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.processedEntities.remove(ObjectIdentifier(pairIdentifier as AnyObject))
        }
    }
    
    
    // MARK: resetWorld 함수
    func resetWorld() {
        view?.scene.anchors.removeAll()
        collisionSubscriptions.forEach { $0.cancel() }
        collisionSubscriptions.removeAll()
        setupARView(view!)
    }
    
    // MARK: loadEntity 함수
    func loadEntity(modelName: String) {
        guard let decoAnchor = decoAnchor else {
            print("Error: decoAnchor가 초기화되지 않았습니다.")
            return
        }
        
        let entity = try! ModelEntity.loadModel(named: "\(modelName)")
        entity.scale /= 2
        entity.generateCollisionShapes(recursive: true)
        entity.collision = CollisionComponent(
            shapes: [.generateBox(size: [0.2, 0.2, 0.2])],
            mode: .trigger,
            filter: .sensor
        )
        entity.physicsBody = PhysicsBodyComponent(massProperties: .default, mode: .dynamic)
        entity.name = "deco"
        
        view?.installGestures(for: entity)
        decoAnchor.addChild(entity)
        
        print("deco가 추가되었고 위치는 \(entity.position(relativeTo: nil))")
        print("decoAnchor 자식의 수: \(decoAnchor.children.count)")
    }
    
    // MARK: loadFXEntity 함수
    func loadFXEntity() {
        guard let sliderValueBinding = sliderValueBinding, sliderValueBinding.wrappedValue < 6 else {
            print("슬라이더가 이미 최대 값입니다.")
            return
        }
        
        // 애니메이션 재생
        if let naevis = naevis, let animation = naevis.availableAnimations.first {
            naevis.playAnimation(animation.repeat(count: 1), transitionDuration: 0.5, startsPaused: false)
        }
        
        let FX = try! ModelEntity.load(named: "heartFX")
        planeAnchor?.addChild(FX)
        print("FX 실행!")
        
        // 슬라이더 값 증가
        DispatchQueue.main.async {
            sliderValueBinding.wrappedValue += 1
            print("슬라이더 값 증가: \(sliderValueBinding.wrappedValue)")
        }
        
        // FX 제거 (3초 뒤)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            FX.removeFromParent()
            print("FX removed after 3 seconds")
        }
    }
}


