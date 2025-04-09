//
//  SliderCell.swift
//  Naevis
//
//  Created by dora on 12/16/24.
//

import SwiftUI

struct SliderCell: View {
    @Binding var sliderValue: Float

    
    var body: some View {
        VStack{
            Text("나이비스에게\n리얼월드 물건을 건네보세요!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            ProgressView(value: sliderValue, total: 6) // 슬라이더처럼 보이도록 ProgressView 사용
                .progressViewStyle(LinearProgressViewStyle())
                .tint(Color.pink.opacity(0.6))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(10)
            Text("남은 물건 \(Int(sliderValue)/2)/3 개")
                .font(.caption)
        }
        .padding(15)
        .background(
            ZStack {
                // Glassmorphism 효과
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial) // 불투명 유리 효과
                    .opacity(0.6)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
        )
        .padding()
        .cornerRadius(10)
        
    }
}


