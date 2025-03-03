//
//  SplashScreenView.swift
//  My BBaller Stats
//
//  Created by Chad Wallace on 2/20/25.
//

import SwiftUI

struct SplashScreenView: View {
    
    @State private var isActive = false
    @State private var size = 0.05
    @State private var opacity = 0.4
    
    var body: some View {
        
        if isActive {
            GameView()
        }
        else {
            VStack{
                
                Spacer()
                
                VStack{
                    Image("WallaceWay")
                        .resizable()
                        .frame(width: 1586, height: 492)
                        .cornerRadius(15.0)
                    Text("")
                        .font(.title)
                        .foregroundColor(.black.opacity(0.80))
                } // end VStack for App image and name
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear{
                    withAnimation(.easeIn(duration: 1.8)) {
                        self.size = 0.2
                        self.opacity = 1.0
                    } // end withAnimation
                    
                } // end onAppear
                
                Spacer()
                

               
            } // end outer VStack
            
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                    withAnimation {
                        self.isActive = true
                    } // end withAnimation
                } // end DispatchQueue
            } // end onAppear
        } // end else
    }
}

#Preview {
    SplashScreenView()
}
