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
                            .clipShape(concentricShape)
                        
                    }
                }
                .containerShape(.rect(cornerRadius: 5))
                .aspectRatio(screenRatio, contentMode: .fit)
                .frame(height: 290)
                .padding(.top, 10)
            
            /// misc UI contenst
            VStack(spacing: 20) {
                indicatorView()
            }
        }
        .padding(.vertical, 30)
        .frame(width: 600)
        .clipShape(.rect(cornerRadius: 30))
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
