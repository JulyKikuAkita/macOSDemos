//
//  XcodeOnBoardingView.swift
//  macOSDemos
//
//  Created by July on 2/7/26.
//

import SwiftUI

struct XcodeOnBoardingDemoView: App {
    var body: some Scene {
        WindowGroup(id: "OnBoarding") {
            XcodeOnBoardingView(foregroundColor: .white, tint: .blue) { isAnimating in
                Image(systemName: "hammer.fill")
                    .font(.system(size: 250))
                    .blendMode(.softLight)
                    .scaleEffect(isAnimating ? 0.5 : 1)
            } content: { isAnimating in
                VStack(spacing: 15) {
                    Text("Welcome to Xcode")
                        .font(.largeTitle.bold())
                    
                    Button(action: {}) {
                        Text("Continue")
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .frame(maxWidth: 230)
                            .padding(.vertical, 12)
                            .background(.blue.gradient, in: .capsule)
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
            }
            .gesture(WindowDragGesture())
        }
        .windowStyle(.plain)
        .restorationBehavior(.disabled)
    }
}

struct XcodeOnBoardingView<Logo: View, Content: View>: View {
    var foregroundColor: Color
    var tint: Color
    var onClose: () -> Void = {}
    @ViewBuilder var logo: (_ isAnimating: Bool) -> Logo
    @ViewBuilder var content: (_ isAnimating: Bool) -> Content
    /// View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var properties: Properties = .init()
    var body: some View {
        let layout = (
            properties.convertToLogo ? AnyLayout(VStackLayout(spacing: 0)) : AnyLayout(ZStackLayout(alignment: .bottom))
        )
        layout {
            ZStack {
                Circle()
                    .fill(tint.gradient)
                    .scaleEffect(properties.animateMAinCircircle ? 2 : 0)
                gridLines()
                circleView()
                circleStokeView()
                diagonalLines()
                
                logo(properties.convertToLogo)
                    .compositingGroup()
                    .blur(radius: properties.convertToLogo ? 0 : 50)
                    .opacity(properties.convertToLogo ? 1 : 0)
                
            }
            .frame(width: properties.convertToLogo ? 200 : 370, height: properties.convertToLogo ? 200 : 450)
            .clipShape(.rect(cornerRadius: properties.convertToLogo ? 50 : 30))
            .contentShape(.rect)
            
            let isAnimating = properties.convertToLogo
            content(isAnimating)
                .visualEffect { content, proxy in
                    content
                        .offset(y: isAnimating ? 0 : proxy.size.height)
                }
                .opacity(isAnimating ? 1 : 0)
        }
        .frame(width: 370, height: 450)
        .overlay(alignment: .topLeading) {
            closeButton()
        }
        .background(.windowBackground)
        .clipShape(.rect(cornerRadius: 30))
        .onAppear {
            /// animating only once
            guard !properties.animateMAinCircircle else { return }

            Task {
                await delayAnimation(0.1, .easeInOut(duration: 0.5)) {
                    properties.animateMAinCircircle = true
                }

                await delayAnimation(0.1, .bouncy(duration: 0.35, extraBounce: 0.2)) {
                    properties.circleScale = 1
                }

                await delayAnimation(0.3, .bouncy(duration: 0.5)) {
                    properties.circleOffset = 50
                }

                await delayAnimation(0.1, .bouncy(duration: 0.4)) {
                    properties.circleSize = 5
                }

                await delayAnimation(0.25, .linear(duration: 0.4)) {
                    properties.positionCircles = true
                }

                await delayAnimation(0.35, .linear(duration: 1)) {
                    properties.animateStrokes = true
                }

                await delayAnimation(0.3, .linear(duration: 0.6)) {
                    properties.animateGridLines = true
                }

                await delayAnimation(0.15, .linear(duration: 0.5)) {
                    properties.animateDiagonalLines = true
                }

                await delayAnimation(0.1, .bouncy(duration: 0.5, extraBounce: 0)) {
                    properties.convertToLogo = true
                }
            }
        }
    }

    func diagonalLines() -> some View {
        ZStack {
            Rectangle()
                .fill(foregroundColor.tertiary)
                .frame(width: 1, height: properties.animateDiagonalLines ? nil : 0)
                .padding(.vertical, -100)
                .frame(maxHeight: .infinity, alignment: .top)
                .rotationEffect(.init(degrees: -39))

            Rectangle()
                .fill(foregroundColor.tertiary)
                .frame(width: 1, height: properties.animateDiagonalLines ? nil : 0)
                .padding(.vertical, -100)
                .frame(maxHeight: .infinity, alignment: .top)
                .rotationEffect(.init(degrees: 39))
        }
        .compositingGroup()
        .opacity(properties.convertToLogo ? 0 : 1)
    }

    func gridLines() -> some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(1...5, id: \.self) { index in
                    Rectangle()
                        .fill(foregroundColor.tertiary)
                        .frame(
                            width: 1,
                            height: properties.animateGridLines ? nil : 0
                        )
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .top
                        )
                        .scaleEffect(y: index == 2 || index == 4 ? -1 : 1)
                }
            }

            VStack(spacing: 0) {
                ForEach(1...5, id: \.self) { index in
                    Rectangle()
                        .fill(foregroundColor.tertiary)
                        .frame(width: properties.animateGridLines ? nil : 0,
                               height: 1)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .leading
                        )
                        .scaleEffect(x: index == 2 || index == 4 ? -1 : 1)
                }
            }
        }
        .compositingGroup()
        .opacity(properties.convertToLogo ? 0 : 1)
    }

    @ViewBuilder
    func circleView() -> some View {
        ZStack {
            ForEach(1...4, id: \.self) { index in
                let rotation = (CGFloat(index) / 4.0) * 360
                let extraRotation: CGFloat = properties.positionCircles ? 20 : 0
                let extraOffset: CGFloat = index % 2 != 0 ? 40 : -20
                let customizedValue: CGFloat = 12
                Circle()
                    .fill(foregroundColor)
                    .frame(
                        width: properties.circleSize,
                        height: properties.circleSize
                    )
                    .animation(.easeInOut(duration: 0.05).delay(0.35)) {
                        $0.scaleEffect(properties.positionCircles ? 0 : 1)
                    }
                    .offset(x: properties.positionCircles ? (120 + extraOffset) : properties.circleOffset)
                    .rotationEffect(.init(degrees: rotation + extraRotation))
                    .animation(.easeInOut(duration: 0.2).delay(0.2)) {
                        $0.rotationEffect(.init(degrees: properties.positionCircles ? customizedValue : 0))
                    }
            }
        }
        .compositingGroup()
        .scaleEffect(properties.circleScale)
    }

    @ViewBuilder
    func circleStokeView() -> some View {
        ZStack {
            /// Inner Circle
            Circle()
                .trim(from: 0, to: properties.animateStrokes ? 1 : 0)
                .stroke(foregroundColor, lineWidth: 1)
                .frame(width: 70, height: 70)
                .scaleEffect(properties.convertToLogo ? 2.5 : 1)

            ForEach(1...4, id: \.self) { index in
                let rotation = (CGFloat(index) / 4.0) * 360
                let customizedValue: CGFloat = 12
                /// 12 comes from customizeValue
                let extraRotation: CGFloat = 20 + customizedValue
                let extraOffset: CGFloat = index % 2 != 0 ? 120 : 0
                /// Fading 2 circles
                let isFaded = index == 3 || index == 4

                Circle()
                    .trim(from: 0, to: properties.animateStrokes ? 1 : 0)
                    .stroke(foregroundColor.opacity(isFaded ? 0.3 : 1), lineWidth: 1)
                    .frame(width: 200 + extraOffset, height: 200 + extraOffset)
                    .rotationEffect(.init(degrees: rotation + extraRotation))
            }
        }
        .compositingGroup()
        .scaleEffect(properties.convertToLogo ? 1.5 : 1)
        .opacity(properties.convertToLogo ? 0 : 1)
    }
    
    func closeButton() -> some View {
        Button {
            dismiss()
            onClose()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.blue) // foregroundColor.tertiary
                .padding(15)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .opacity(properties.convertToLogo ? 1 : 0)
    }

    /// Animation Properties
    struct Properties {
        var animateMAinCircircle: Bool = false
        /// Circle Properties
        var circleSize: CGFloat = 50
        var circleOffset: CGFloat = 0
        var circleScale: CGFloat = 0
        var positionCircles: Bool = false
        var animateStrokes: Bool = false
        var animateGridLines: Bool = false
        var animateDiagonalLines: Bool = false
        var convertToLogo: Bool = false
    }

    func delayAnimation(_ delay: Double, _ animation: Animation, perform action: @escaping () -> Void) async {
        try? await Task.sleep(for: .seconds(delay))
        withAnimation(animation) {
            action()
        }
    }
}

#Preview {
    XcodeOnBoardingView(foregroundColor: .white, tint: .blue) { isAnimating in
        Image(systemName: "hammer.fill")
            .font(.system(size: 250))
            .blendMode(.softLight)
            .scaleEffect(isAnimating ? 0.5 : 1)
    } content: { isAnimating in
        VStack(spacing: 15) {
            Text("Welcome to Xcode")
                .font(.largeTitle.bold())
            
            Button(action: {}) {
                Text("Continue")
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: 230)
                    .padding(.vertical, 12)
                    .background(.blue.gradient, in: .capsule)
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 20)
    }
}
