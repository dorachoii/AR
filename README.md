## 🧑‍🎤 一言紹介

[SMバーチャルミュージシャン Naevis](https://naevisofficial.com/)のポップアップ展示体験用 **ARゲーム**。

異世界から来た **Naevis に地球のものを教えて、親密度を上げる** コンセプト。

## 📹 プレイ動画
https://www.youtube.com/shorts/xhghoX2gcs4


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

![세로_1.gif](attachment:89ca35ca-217b-4add-9d70-b2d465f6b977:세로_1.gif)

### 🔧 実装概要

キャラクターとアイテムが衝突した際に、アイテムが消える処理をRealityKitで実装しました。

### 🔧 UnityとRealityKitの違い

- `Unity`: 各GameObjectのComponentで処理
- `RealityKit`: 全体のCollisionEventで処理

Unityでは、ゲームオブジェクトにコンポーネントとしてスクリプトをアタッチする形式のため、**衝突した主体のオブジェクトと衝突されたオブジェクトを明確に区別**することができます。

しかし、RealityKitでは衝突イベント`Collision Event`自体を検知し、特定のルールで`entityA`と`entityB`が割り当てられる仕組みになっています。それで、キャラクターとアイテムが衝突した際に、ランダムでキャラクターが消えてしまいました。

そこで、Entityを生成する際**、**名前を付けておき、衝突時にその名前を基準に削除することで、この問題を解決しました。



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

```swift
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

</details>
<details>
<summary>② RealityKitにおけるModelEntityのアニメーション制御</summary>
![Blenderからエクスポート](attachment:c39165c4-a24c-4be0-9ec4-4198162b23ea:01_ISSAC_1.gif)


### 🔧 実装概要
Reality Composer Proには、UnityのAnimatorのように、アニメーション状態を一元管理する機能がなかったため、コードベースで実装しました。

また、Blender側で複数のアニメーションを配列として格納し、それをRealityKit側で切り替える方法が存在する可能性がありますが、現時点ではその具体的な実装方法がわかりませんでした。


### 💻 ソースコード
```swift
// .usdzファイルに埋め込まれたアニメーション再生
if let naevis = naevis, let animation = naevis.availableAnimations.first {
     naevis.playAnimation(animation.repeat(count: 1), transitionDuration: 0.5, startsPaused: false)
}
</details>
<details>
<summary>③ Reality Composer Proを活用したパーティクルの生成</summary>

![Reality Composer Pro](attachment:c9e5cf40-e099-4662-9a89-212ef540b2f8:01_ISSAC.gif)


### 🔧 実装概要
RealityComposerProで作成したパーティクルを.usdz形式でエクスポートし、コードで読み込んで使用しました。

### 💻 ソースコード
```swift
// RealityComposerProで作成したパーティクルを.usdzとしてエクスポート、ModelEntityとして生成する方法
let FX = try! ModelEntity.load(named: "heartFX")

</details>
## 🔎 振り返り
###学んだこと
- Unityなどのゲームエンジンではなく、Xcode上で3Dインタラクションを実装してみました。
- RealityKitで使用できる拡張子は一般的に使われる.fbxではなく.usdzであるため、マテリアルやアニメーションを.usdzに合わせて変換して抽出する過程で苦労しましたが、3D拡張子についての理解を深めることができました。
- 3Dモデルファイルが大きいため、アプリがクラッシュする問題がありましたが、非同期ロード処理などで改善しました。

###改善点
- 多様なアニメーションを実装したかったのですが、RealityKitのアニメーションに関する内部構造の情報が少なく、最終的に2種類のアニメーションを繰り返すだけになってしまったのが残念でした。
- ARKitの座標系についてはまだ理解が不十分で、分析を試みたものの、表面でのアイテムのスポーン位置が毎回異なってしまいます。
- Unityでの衝突処理には慣れているのですが、RealityKitにおいては、衝突オブジェクトであるEntityAとEntityBをどのようにフィルタリングして処理するか悩んでおり、現在の実装が最適だとは思っていません。

