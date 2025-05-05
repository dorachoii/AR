## 🧑‍🎤 一言紹介

[SMバーチャルミュージシャン Naevis](https://naevisofficial.com/)のポップアップ展示体験用 **ARゲーム**。

異世界から来た **Naevis に地球のものを教えて、親密度を上げる** コンセプト。



## 👥 開発人数

- プログラマー：1名  
- モデラー：1名  



## 🗓 開発期間

**2週間（2024年10月）**



## 🛠 担当部分

- ARインタラクション全体の設計と実装  
- Reality Composer Pro を用いたパーティクルエフェクトの制作  
- Xcode 上で `.usdz` アニメーションおよびグラフィック制御の実装  


## 🦦 アピールポイントと挑戦課題

<details>
<summary>① RealityKitにおける衝突管理</summary>

### 🔧 実装概要

キャラクターとアイテムが衝突した際に、**アイテムが消える処理**をRealityKitで実装しました。Unityと異なり、RealityKitでは個別のGameObjectではなく**全体的なイベントベースで衝突を検知**するため、衝突時にランダムでキャラクターが消えてしまう問題がありました。

→ その対策として、Entityに名前をつけ、衝突したエンティティの名前を条件으로削除する方法を採用しました。

---

### 💻 ソースコード

```swift
//MARK: - Entityを生成する関数
func loadEntity(modelName: String) {
    guard let decoAnchor = decoAnchor else { return }

    let entity = try! ModelEntity.loadModel(named: "\(modelName)")

    // 衝突判定に必要① CollisionShapeの生成
    entity.generateCollisionShapes(recursive: true)

    // 衝突判定に必要② CollisionComponentの設定 - mode: trigger 
    entity.collision = CollisionComponent(
        shapes: [.generateBox(size: [0.2, 0.2, 0.2])],
        mode: .trigger,
        filter: .sensor
    )

    // 衝突判定に必要③ PhysicsBodyComponentの追加  - mode: dynamic
    entity.physicsBody = PhysicsBodyComponent(massProperties: .default, mode: .dynamic)

    // 衝突時に識別できるように名前を設定
    entity.name = "deco"

    view?.installGestures(for: entity)
    decoAnchor.addChild(entity)
}

// MARK: - 衝突処理
private func handleCollision(event: CollisionEvents.Began) {
    guard let entityA = event.entityA as? ModelEntity,
          let entityB = event.entityB as? ModelEntity else { return }

    // キャラクターモデルのColliderが複数重なっており、衝突が重複発生
    // hash識別子で一度だけ処理されるように制御
    let pairIdentifier = entityA.hashValue ^ entityB.hashValue
    guard !processedEntities.contains(ObjectIdentifier(pairIdentifier as AnyObject)) else { return }
    processedEntities.insert(ObjectIdentifier(pairIdentifier as AnyObject))

    // "deco"だけを消すように条件分岐
    if (entityA.name == "naevis" && entityB.name == "deco") {
        entityB.removeFromParent()
        loadFXEntity()
    } else if (entityA.name == "deco" && entityB.name == "naevis") {
        entityA.removeFromParent()
        loadFXEntity()
    }

    // 一定時間後に識別子をクリアして再衝突可能に
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
        self?.processedEntities.remove(ObjectIdentifier(pairIdentifier as AnyObject))
    }
}
