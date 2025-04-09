//
//  BuildingInnerMapView.swift
//  Naeilmalhalgang
//
//  Created by dora on 11/11/24.
//

import SwiftUI
import RealityKit
import Combine

struct BuildingThreeDMapView: View {
    
    var mapNames: [(name: String, index: Int)]
    @Binding var selectedMapIndex: Int
    @State private var isLoading = true             // 모델 불러오기 전 프로그래스뷰 띄우기 위한 변수
    @State private var isModelAvailable = true      // 모델 존재 여부를 판단하는 변수
    
    var body: some View {
        ZStack {
            if isModelAvailable {
                ARInnerMapContainer(
                    selectedMapIndex: $selectedMapIndex,
                    mapNames: mapNames,
                    isLoading: $isLoading,
                    isModelAvailable: $isModelAvailable
                )
                .ignoresSafeArea(.all)
            } else {
                Text("준비 중 입니다.")
                    //.pretendard(weight: .bold, size: 24)
                    .foregroundColor(.gray)
            }
            
            if isLoading {
                ProgressView("Loading Map...")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
            }
        }
    }
}

struct ARInnerMapContainer: UIViewRepresentable {
    @Binding var selectedMapIndex: Int
    var mapNames: [(name: String, index: Int)]
    @Binding var isLoading: Bool
    @Binding var isModelAvailable: Bool
    
    func makeUIView(context: Context) -> some UIView {
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.white)
        
        // MARK: - 비동기 모델 로딩
        Task {
            do {
                // MARK: - 모델 이름 확인
                let modelName = mapNames[selectedMapIndex].name
                guard !modelName.isEmpty else {
                    throw NSError(domain: "ModelNameError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invalid map name."])
                }
                
                // 모델 로드
                let innerMapModel = try await ModelEntity(named: modelName)
                
                let mapEntity = ModelEntity()
                mapEntity.addChild(innerMapModel)
                mapEntity.generateCollisionShapes(recursive: true)
                arView.installGestures([.scale, .rotation], for: mapEntity)
                
                let mapAnchor = AnchorEntity(world: [0, 0, 0])
                mapAnchor.addChild(mapEntity)
                arView.scene.anchors.append(mapAnchor)
                
                // 카메라 설정
                let camera = PerspectiveCamera()
                camera.position = [0, 2, 2]
                camera.look(at: mapAnchor.position, from: camera.position, relativeTo: nil)
                
                let cameraAnchor = AnchorEntity(world: [0, 0, 0])
                cameraAnchor.addChild(camera)
                arView.scene.addAnchor(cameraAnchor)
                
                // 로드 성공
                DispatchQueue.main.async {
                    isLoading = false
                    isModelAvailable = true
                }
            } catch {
                print("Error loading model: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                    isModelAvailable = false
                }
            }
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

//
//  ARViewContainer.swift
//  Naevis
//
//  Created by dora on 12/11/24.
//

//import SwiftUI
//import RealityKit
//import ARKit
//import Combine
//
//
//let itemGroup = CollisionGroup(rawValue: 1 << 0)
//let characterGroup = CollisionGroup(rawValue: 1 << 1)
//
//struct ARNaevisView:View{
//    @ObservedObject var coordinator:Coordinator
//    @State private var showAlert = false
//    @State var selectedItem: String = ""
//    @State var sliderValue: Float = 0.0
//    
//    @State private var selectedView: ViewType = .arView
//    
//    var body: some View{
//        ZStack{
//            ZStack{
//                ARViewContainer(coordinator: coordinator, sliderValue: $sliderValue)
//                    .ignoresSafeArea()
//                VStack{
//                    Spacer()
//                        .frame(height: 100)
//                    
//                    SliderCell(sliderValue: $sliderValue)
//                    Spacer()
//                    HStack {
//                        Spacer()
//                        FloatingInventoryView(
//                            selectedItem: $selectedItem,
//                            coordinator: coordinator
//                        )
//                        .padding()
//                    }
//                }
//            }
//            if showAlert{
//                Color.black.opacity(0.6) // 어두운 배경
//                .ignoresSafeArea()
//            }
//        }
//        .alert("나이비스에게 리얼월드를 알려줘서 고마워!", isPresented: $showAlert) {
//            Button("다시 시작하기") {
//                sliderValue = 0
//                coordinator.resetWorld()
//            }
//        }
//        .onChange(of: sliderValue) {
//            if sliderValue >= 6 {
//                showAlert = true
//            }
//        }
//    }
//}

//struct ARViewContainer: UIViewRepresentable {
//    @ObservedObject var coordinator: Coordinator
//    @Binding var sliderValue: Float
//    
//    func makeUIView(context: Context) -> ARView {
//        coordinator.sliderValue = sliderValue
//        
//        let arView = ARView(frame: .zero)
//        arView.debugOptions = [.showAnchorOrigins]
//        
//        // planeAnchor 생성 및 위치 설정
//        let planeAnchor = AnchorEntity(plane: .horizontal)
//        
//        // naevis 모델 추가
//        let naevis = try! ModelEntity.loadModel(named: "naevisDance2")
//        naevis.scale /= 3
//        naevis.name = "naevis"
//        naevis.generateCollisionShapes(recursive: true)
//        planeAnchor.addChild(naevis)
//        
//        // decoAnchor를 planeAnchor 기준으로 Y축으로 3 단위 위로 설정
//        let decoAnchor = AnchorEntity()
//        decoAnchor.setPosition(SIMD3<Float>(0, 0, -0.3), relativeTo: planeAnchor)
//        
//        print("decoAnchor 위치는 \(decoAnchor.position(relativeTo: nil))")
//        print("planeAnchor 위치는 \(planeAnchor.position(relativeTo: nil))")
//        
//        // Coordinator에 참조 설정
//        coordinator.naevis = naevis
//        coordinator.decoAnchor = decoAnchor
//        coordinator.planeAnchor = planeAnchor
//        
//        // 앵커 추가
//        arView.scene.addAnchor(planeAnchor)
//        arView.scene.addAnchor(decoAnchor)
//        
//        // 바닥 앵커 추가
//        let floorAnchor = AnchorEntity(plane: .horizontal)
//        let floor = ModelEntity(mesh: MeshResource.generateBox(size: [50, 0, 50]), materials: [OcclusionMaterial()])
//        floor.generateCollisionShapes(recursive: true)
//        floor.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
//        floorAnchor.addChild(floor)
//        arView.scene.addAnchor(floorAnchor)
//        
//        coordinator.view = arView
//        
//        // 충돌 이벤트 구독 설정
//        context.coordinator.collisionSubscriptions.append(arView.scene.subscribe(to: CollisionEvents.Began.self) { event in
//            guard let entityA = event.entityA as? ModelEntity,
//                  let entityB = event.entityB as? ModelEntity else { return }
//            
//            print("충돌 발생")
//            print("A는 \(entityA.name)")
//            print("B는 \(entityB.name)")
//            
//            if entityA.name == "naevis" && entityB.name == "deco" {
//                entityB.removeFromParent()
//                coordinator.loadFXEntity(sliderValue: $sliderValue)
//            } else if entityA.name == "deco" && entityB.name == "naevis" {
//                entityA.removeFromParent()
//                coordinator.loadFXEntity(sliderValue: $sliderValue)
//            }
//        })
//        
//        return arView
//    }
//    
//    
//    func updateUIView(_ uiView: UIViewType, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//}
//
//
//class Coordinator: NSObject, ObservableObject {
//    var view: ARView?
//    var naevis: ModelEntity?
//    var planeAnchor: AnchorEntity?
//    var decoAnchor: AnchorEntity?
//    var collisionSubscriptions = [Cancellable]()
//    var sliderValue: Float?
//    
//    // MARK: resetWorld 함수
//    func resetWorld() {
//        view?.scene.anchors.removeAll()
//        view?.session.run()
//    }
//    
//    // MARK: loadEntity 함수
//    func loadEntity(modelName: String) {
//        guard let decoAnchor = decoAnchor else {
//            print("Error: decoAnchor가 초기화되지 않았습니다.")
//            return
//        }
//        
//        let entity = try! ModelEntity.loadModel(named: "\(modelName)")
//        entity.scale /= 2
//        entity.generateCollisionShapes(recursive: true)
//        entity.collision = CollisionComponent(
//            shapes: [.generateBox(size: [0.2, 0.2, 0.2])],
//            mode: .trigger,
//            filter: .sensor
//        )
//        entity.physicsBody = PhysicsBodyComponent(massProperties: .default, mode: .dynamic)
//        entity.name = "deco"
//        
//        // 제스처 설치
//        view?.installGestures(for: entity)
//        
//        // decoAnchor에 자식 추가
//        decoAnchor.addChild(entity)
//        
//        print("deco가 추가되었고 위치는 \(entity.position(relativeTo: nil))")
//        print("decoAnchor 자식의 수: \(decoAnchor.children.count)")
//    }
//    
//    // MARK: loadFXEntity 함수
//    func loadFXEntity(sliderValue: Binding<Float>) {
//        
//        guard sliderValue.wrappedValue < 6 else {
//            print("슬라이더가 이미 최대 값입니다.")
//            return
//        }
//        
//        // 애니메이션 재생
//        if let naevis = naevis, let animation = naevis.availableAnimations.first {
//            naevis.playAnimation(animation.repeat(count: 1), transitionDuration: 0.5, startsPaused: false)
//        }
//        
//        let FX = try! ModelEntity.load(named: "heartFX")
//        planeAnchor?.addChild(FX)
//        print("FX 실행!")
//        
//        // 슬라이더 값 증가
//        DispatchQueue.main.async {
//            sliderValue.wrappedValue += 1
//            print("슬라이더 값 증가: \(sliderValue.wrappedValue)")
//        }
//        
//        // FX 제거 (3초 뒤)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            FX.removeFromParent()
//            print("FX removed after 3 seconds")
//        }
//    }
//}
