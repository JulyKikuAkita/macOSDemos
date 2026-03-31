//
//  XcodeOnBoardingView.swift
//  macOSDemos
//
//  Created by July on 3/30/26.
//

import SwiftUI

@main
@available(macOS 26.0, *)
struct macOSOnBoardingDemo26App: App {
    var body: some Scene {
        XcodeOnBoarding26Window(items: sampleOnBoardingMenuItems) {
            print("Closed")
        } onSkip: {
            print("Skip")
        } onComplete: {
            print("Completed")
        }
    }
}

@available(macOS 26.0, *)
struct XcodeOnBoarding26Window: Scene {
    var items: [OnBoardingItem]
    var onExit: () -> Void
    var onSkip: () -> Void
    var onComplete: () -> Void
    var body: some Scene {
        WindowGroup(id: "OnBoarding") {
            XcodeOnBoarding26View(
                items: items,
                onExit: onExit,
                onSkip: onSkip,
                onComplete: onComplete
            )
            .contentShape(.rect)
            .gesture(WindowDragGesture())
        }
        .windowStyle(.plain)
        .restorationBehavior(.disabled)
        .windowBackgroundDragBehavior(.enabled)
    }
}

@available(macOS 26.0, *)
fileprivate struct XcodeOnBoarding26View: View {
    var items: [OnBoardingItem]
    var onExit: () -> Void
    var onSkip: () -> Void
    var onComplete: () -> Void
    /// View Properties
    @State private var activeIndex: Int = 0
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(.clear)
                .overlay {
                    /// Bezel Design and animating screenshots
                    ZStack {
                        concentricShape
                            .fill(.black)
                        bezelDesign()
                        
                        screenshotView(items[activeIndex])
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .compositingGroup()
                        /// option 1: same effect as option 2 using keyframeAnimator
                            .animation(.easeInOut(duration: 0.35), value: activeIndex)
                        /// option2: animation with keyframeAnimator
//                            .keyframeAnimator(initialValue: CGFloat.zero, trigger: activeIndex) { content, blur in
//                                content
//                                    .blur(radius: blur)
//                            } keyframes: { _ in
//                                CubicKeyframe(25, duration: 0.25)
//                                CubicKeyframe(0, duration: 0.25)
//                            }
                            .clipShape(concentricShape)
                        
                    }
                }
                .containerShape(.rect(cornerRadius: 5))
                .aspectRatio(screenRatio, contentMode: .fit)
                .frame(height: 290)
                .padding(.top, 10)
                /// Zoom animation
                .compositingGroup()
                .scaleEffect(items[activeIndex].zoomScale, anchor: items[activeIndex].zoomAnchor)
            
            /// misc UI content
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    indicatorView()
                        .offset(y: 10)
                    
                    textContentView()
                }
                .padding(.top, 30)
                
                continueButton()
                    .padding(.top, 20)
            }
            .background(variableBackground())
        }
        .padding(.vertical, 30)
        .overlay(alignment: .top) {
            HStack {
                Button {
                    if activeIndex == 0{
                        onExit()
                    } else {
                        withAnimation(.smooth(duration: 0.5, extraBounce: 0)) {
                            activeIndex = max(activeIndex - 1, 0)
                        }
                    }
                } label: {
                    Image(systemName: activeIndex == 0 ? "xmark": "chevron.left")
                        .font(.caption)
                        .contentTransition(.symbolEffect)
                        .foregroundStyle(.secondary)
                        .frame(width: 25, height: 25)
                        .background(.ultraThinMaterial, in: .circle)
                }
                
                Spacer(minLength: 0)
                
                Button {
                    onSkip()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 25, height: 25)
                        .background(.ultraThinMaterial, in: .circle)
                }
            }
            .buttonStyle(.plain)
            .padding(12)
        }
        .frame(width: 600)
        .clipShape(.rect(cornerRadius: 30).inset(by: 0.6))
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.windowBackground)
                
                // border
                RoundedRectangle(cornerRadius: 30)
                    .stroke(.gray.opacity(0.2), lineWidth: 1.2)
            }
        }
        
    }
    
    @ViewBuilder
    func screenshotView(_ item: OnBoardingItem) -> some View {
        if let image = item.screenshot {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
    
    func bezelDesign() -> some View {
        ZStack(alignment: .top) {
            concentricShape
                .stroke(macbookTint, lineWidth: 4)
            
            concentricShape
                .stroke(.black, lineWidth: 3)
            concentricShape
                .stroke(.black, lineWidth: 3)
                .padding(2)
            
            /// Notch
            bottomOnlyCornerRadiusShape(3)
                .fill(.black)
                .frame(width: 50, height: 8)
                .offset(y: 3.5)
            
            /// Bottom keyboard
            bottomOnlyCornerRadiusShape(5)
                .fill(macbookTint)
                .overlay(alignment: .top) {
                    /// trackpad
                    bottomOnlyCornerRadiusShape(4)
                        .fill(.black.opacity(0.3))
                        .frame(width: 45, height: 4)
                }
                .frame(height: 10)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, -35)
                .offset(y: 9)
        }
        .padding(-3)
    }
    
    func indicatorView() -> some View {
        HStack(spacing: 6) {
            ForEach(items.indices, id: \.self) { index in
                let isActive: Bool = activeIndex == index
                
                Capsule()
                    .fill(activeTint.opacity(isActive ? 1 : 0.4))
                    .frame(width: isActive ? 25 : 6, height: 6)
            }
        }
        .padding(.bottom, 5)
    }
    
    func textContentView() -> some View {
        ZStack {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                let isActive: Bool = activeIndex == index
                
                VStack(spacing: 6) {
                    Text(item.title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundStyle(activeTint)
                    
                    Text(item.subtitle)
                        .font(.title3)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(activeTint.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .compositingGroup()
                .opacity(isActive ? 1 : 0)
            }
        }
        .compositingGroup()
        .keyframeAnimator(initialValue: CGFloat.zero, trigger: activeIndex) { content, blur in
            content
                .blur(radius: blur)
        } keyframes: { _ in
            CubicKeyframe(25, duration: 0.25)
            CubicKeyframe(0, duration: 0.25)
        }
        .clipShape(concentricShape)
    }
    
    func continueButton() -> some View {
        Button {
            if activeIndex == items.count - 1 {
                onComplete()
            } else {
                withAnimation(.smooth(duration: 0.5, extraBounce: 0)) {
                    activeIndex = min(activeIndex + 1, items.count - 1)
                }
            }
        } label: {
            Text(activeIndex == items.count - 1 ? "Get Started" : "Continue")
                .fontWeight(.medium)
                .contentTransition(.numericText())
                .foregroundStyle(.primary)
                .frame(width: 300, height: 45)
                .background(buttonTint.gradient, in: .capsule)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
    }
    
    func variableBackground() -> some View {
        Rectangle()
            .fill(.windowBackground)
            .mask {
                LinearGradient(colors: [
                    .black,
                    .black,
                    .black,
                    .black.opacity(0.9),
                    .black.opacity(0.4),
                    .clear
                ], startPoint: .bottom, endPoint: .top)
            }
            .padding(.top, -30)
            .padding(.bottom, -50)
    }
    
    var activeTint: Color {
        .white
    }
    
    var buttonTint: Color {
        .blue
    }
    
    var macbookTint: Color {
        Color(red: 0.75, green: 0.75, blue: 0.78)
    }
    
    func bottomOnlyCornerRadiusShape(_ radius: CGFloat) -> AnyShape {
        .init(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: radius,
                bottomTrailingRadius: radius,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
    }
    
    /// default to MBP screen ratio
    var screenRatio: CGFloat {
        1.547
    }
    
    let concentricShape = ConcentricRectangle(
        topLeadingCorner: .concentric,
        topTrailingCorner: .concentric,
        bottomLeadingCorner: .fixed(0),
        bottomTrailingCorner: .fixed(0)
    )
}

@available(macOS 26.0, *)
#Preview {
    XcodeOnBoarding26View(items: sampleOnBoardingMenuItems){
        
    } onSkip: {
        
    } onComplete: {
        
    }
}
