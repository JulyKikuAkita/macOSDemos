//
//  XcodeOnBoardingView.swift
//  macOSDemos
//
//  Created by July on 2/7/26.
//

import SwiftUI

struct XcodeOnBoardingDemoView: View {
    var body: some View {

    }
}

struct XcodeOnBoardingView<Logo: View, Content: View>: View {
    var foregroundColor: Color
    var tint: Color
    @ViewBuilder var logo: (_ isAnimating: Bool) -> Logo
    @ViewBuilder var content: (_ isAnimating: Bool) -> Content
    /// View Properties
    @State private var properties: Properties = .init()
    var body: some View {
        ZStack {
            Circle()
                .fill(tint.gradient)
                .scaleEffect(properties.animateMAinCircircle ? 2 : 0)
            gridLines()
            circleView()
            circleStokeView()
        }
        .frame(width: 370, height: 450)
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
            }
        }
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

            ForEach(1...4, id: \.self) { index in
                let rotation = (CGFloat(index) / 4.0) * 360
                let customizedValue: CGFloat = 12
                /// 12 comes from customizeValue
                let extraRotation: CGFloat = 20 + customizedValue
                let extraOffset: CGFloat = index % 2 != 0 ? 40 : -20
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

    } content: { isAnimating in

    }
}
