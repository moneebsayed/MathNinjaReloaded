//
//  AboutView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    NinjaTitle("About Math Ninja")
                    
                    MenuCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("🥷 Master multiplication through ninja-style slicing!")
                            Text("🎯 Choose your difficulty and slice the correct answers")
                            Text("⏰ Beat the clock to achieve high scores")
                            Text("🌟 Perfect your math skills while having fun")
                        }
                        .foregroundColor(Theme.textPrimary)
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.primaryColor)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
