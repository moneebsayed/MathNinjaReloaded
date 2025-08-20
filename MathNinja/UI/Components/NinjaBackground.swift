//
//  NinjaBackground.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

// MARK: - Animated Background
struct NinjaBackground: View {
    @State private var animateElements = false
    @State private var cloudOffset: CGFloat = -100
    @State private var starsOpacity: Double = 0.3
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Base environment gradient
            backgroundEnvironment
                .ignoresSafeArea()
                .accessibilityIdentifier("BackgroundEnvironment")
            
            // Environmental elements
            environmentalElements
                .accessibilityIdentifier("EnvironmentalElements")
            
            // Floating particles/energy
            floatingParticles
                .accessibilityIdentifier("FloatingParticles")
        }
        .accessibilityIdentifier("NinjaBackground")
        .accessibilityHidden(true) // Hide decorative background from screen readers
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Background Environment
    private var backgroundEnvironment: some View {
        ZStack {
            // Primary background
            Theme.dojoGradient
                .accessibilityHidden(true)
            
            // Mountain silhouettes (background layer)
            if colorScheme == .light {
                lightModeEnvironment
                    .accessibilityHidden(true)
            } else {
                darkModeEnvironment
                    .accessibilityHidden(true)
            }
        }
    }
    
    // MARK: - Light Mode Environment (Training Dojo)
    private var lightModeEnvironment: some View {
        ZStack {
            // Wooden floor planks effect
            VStack(spacing: 0) {
                Spacer()
                ForEach(0..<3, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.brown.opacity(0.1))
                        .frame(height: 2)
                        .padding(.horizontal)
                }
                .padding(.bottom, 50)
            }
            .accessibilityHidden(true)
            
            // Paper doors/windows effect
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 3)
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 3)
            }
            .padding(.horizontal, 30)
            .accessibilityHidden(true)
        }
    }
    
    // MARK: - Dark Mode Environment (Mystical Night)
    private var darkModeEnvironment: some View {
        ZStack {
            // Mountain silhouettes
            VStack {
                Spacer()
                HStack {
                    // Left mountain
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 200))
                        path.addLine(to: CGPoint(x: 150, y: 50))
                        path.addLine(to: CGPoint(x: 300, y: 180))
                        path.addLine(to: CGPoint(x: 0, y: 180))
                    }
                    .fill(Color.black.opacity(0.3))
                    .accessibilityHidden(true)
                    
                    Spacer()
                    
                    // Right mountain
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 150))
                        path.addLine(to: CGPoint(x: 100, y: 30))
                        path.addLine(to: CGPoint(x: 200, y: 160))
                        path.addLine(to: CGPoint(x: 0, y: 160))
                    }
                    .fill(Color.black.opacity(0.2))
                    .accessibilityHidden(true)
                }
                .frame(height: 200)
            }
            
            // Clouds
            cloudsLayer
                .accessibilityHidden(true)
            
            // Stars
            starsLayer
                .accessibilityHidden(true)
        }
    }
    
    // MARK: - Environmental Elements
    private var environmentalElements: some View {
        ZStack {
            // Animated clouds (for both modes, but more visible in dark)
            if colorScheme == .dark {
                cloudsLayer
                    .opacity(0.6)
                    .accessibilityHidden(true)
            }
            
            // Mist/fog effect
            ForEach(0..<3, id: \.self) { i in
                Ellipse()
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.03 : 0.08))
                    .frame(width: 300, height: 100)
                    .offset(x: CGFloat(i * 100 - 150), y: CGFloat(200 + i * 50))
                    .scaleEffect(animateElements ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: Double(3 + i))
                        .repeatForever(autoreverses: true),
                        value: animateElements
                    )
                    .accessibilityHidden(true)
            }
        }
    }
    
    // MARK: - Clouds Layer
    private var cloudsLayer: some View {
        HStack {
            ForEach(0..<3, id: \.self) { i in
                Ellipse()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat(60 + i * 20), height: CGFloat(30 + i * 10))
                    .offset(x: cloudOffset + CGFloat(i * 150))
                    .animation(
                        .linear(duration: Double(15 + i * 5))
                        .repeatForever(autoreverses: false),
                        value: cloudOffset
                    )
                    .accessibilityHidden(true)
            }
        }
        .onAppear {
            cloudOffset = UIScreen.main.bounds.width + 100
        }
    }
    
    // MARK: - Stars Layer
    private var starsLayer: some View {
        ForEach(0..<15, id: \.self) { i in
            Circle()
                .fill(Color.white.opacity(starsOpacity))
                .frame(width: CGFloat.random(in: 1...3))
                .position(
                    x: CGFloat.random(in: 20...UIScreen.main.bounds.width - 20),
                    y: CGFloat.random(in: 50...200)
                )
                .animation(
                    .easeInOut(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: true),
                    value: starsOpacity
                )
                .accessibilityHidden(true)
        }
    }
    
    // MARK: - Floating Particles
    private var floatingParticles: some View {
        ForEach(0..<12, id: \.self) { i in
            Circle()
                .fill(Theme.adaptivePrimaryColor.opacity(0.1))
                .frame(width: CGFloat.random(in: 3...8))
                .position(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                )
                .scaleEffect(animateElements ? 1.5 : 0.8)
                .animation(
                    .easeInOut(duration: Double.random(in: 3...6))
                    .repeatForever(autoreverses: true),
                    value: animateElements
                )
                .accessibilityHidden(true)
        }
    }
    
    // MARK: - Animation Control
    private func startAnimations() {
        withAnimation {
            animateElements = true
        }
        
        // Animate stars
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            starsOpacity = colorScheme == .dark ? 0.8 : 0.1
        }
        
        // Start cloud movement
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                cloudOffset = -UIScreen.main.bounds.width - 200
            }
        }
    }
}
