//
//  GameView.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 10/21/22.
//

import Foundation
import SwiftUI
import Observation

struct GameView: View {

    @Environment(Game.self) private var game
    
    @State private var showFix = false
    @State private var made2IsPressed = false
    @State private var missed2IsPressed = false
    @State private var made3IsPressed = false
    @State private var missed3IsPressed = false
    @State private var madeFTIsPressed = false
    @State private var missedFTIsPressed = false
    @State private var assistIsPressed = false
    @State private var reboundIsPressed = false
    @State private var stealIsPressed = false
    @State private var blockIsPressed = false
    @State private var turnoverIsPressed = false
    @State private var foulIsPressed = false
    @State private var undomade2IsPressed = false
    @State private var undomissed2IsPressed = false
    @State private var undomade3IsPressed = false
    @State private var undomissed3IsPressed = false
    @State private var undomadeFTIsPressed = false
    @State private var undomissedFTIsPressed = false
    @State private var undoassistIsPressed = false
    @State private var undoreboundIsPressed = false
    @State private var undostealIsPressed = false
    @State private var undoblockIsPressed = false
    @State private var undoturnoverIsPressed = false
    @State private var undofoulIsPressed = false




    // Style information for Green button
    struct GreenButton: ButtonStyle {
        var deviceHeight: CGFloat {
            UIScreen.main.bounds.height
        }
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: deviceHeight * 0.135, height: deviceHeight * 0.135)
                .multilineTextAlignment(.center)
                .font(.system(size: deviceHeight/770 * 21, weight: .bold))
                .foregroundColor(Color.white)
                .background(Color(UIColor(red:0/255, green: 100/255, blue: 0/255, alpha: 1.0)))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 4))
                .padding(.leading,3)
                .padding(.bottom,3)
                .padding(.trailing,3)
            
        }
    }
    
    
    // Style information for Red button
    struct RedButton: ButtonStyle {
        var deviceHeight: CGFloat {
            UIScreen.main.bounds.height
        }
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: deviceHeight * 0.135, height:deviceHeight * 0.135)
                .multilineTextAlignment(.center)
                .font(.system(size: deviceHeight/770 * 21, weight: .bold))
                .foregroundColor(Color.white)
                .background(Color(UIColor(red:178/255, green: 34/255, blue: 34/255, alpha: 1.0)))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 4))
                .padding(.leading,3)
                .padding(.bottom,3)
                .padding(.trailing,3)
        }
    }
    
    var deviceHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    // This is the Game View
    var body: some View {
        NavigationStack{
            
            // vertical the whole GameView screeen
        VStack {
        
            Spacer()
            // Stats
            StatsView()
            
//            Text("             ")
Spacer()
            
            // if fix Toggle is off, show regular buttons
            if !showFix {
                
            // Regular button VStack
                VStack{
                    
                    // HStack the basket buttons with the divider and reb/asst/to buttons
                    HStack{
                        
                        // Basket buttons
                        VStack{
                            
                            // 2-pointers
                            HStack{
                                Button(" Made    2 pt"){
                                    game.makeTwo()
                                }
                                .buttonStyle(GreenButton())
                                .scaleEffect(made2IsPressed ? 1.1 : 1.0)
                                .opacity(made2IsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        made2IsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        made2IsPressed = false
                                    }
                                }
                                
                                Button("Missed 2 pt"){
                                    game.missTwo()
                                }
                                .buttonStyle(RedButton())
                                .scaleEffect(missed2IsPressed ? 1.1 : 1.0)
                                .opacity(missed2IsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        missed2IsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        missed2IsPressed = false
                                    }
                                }
                                
                            } // end Hstack 2-pointers
                            
                            // 3-pointers
                            HStack{
                                Button("Made   3 pt"){
                                    game.makeThree()
                                }
                                .buttonStyle(GreenButton())
                                .scaleEffect(made3IsPressed ? 1.1 : 1.0)
                                .opacity(made3IsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        made3IsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        made3IsPressed = false
                                    }
                                }

                                
                                Button("Missed 3 pt"){
                                    game.missThree()
                                }
                                .buttonStyle(RedButton())
                                .scaleEffect(missed3IsPressed ? 1.1 : 1.0)
                                .opacity(missed3IsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        missed3IsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        missed3IsPressed = false
                                    }
                                }
                                
                            } // end Hstack 3 pters
                            
                            // Free Throws
                            HStack{
                                Button("Made    Free Throw"){
                                    game.makeFT()
                                }
                                .buttonStyle(GreenButton())
                                .scaleEffect(madeFTIsPressed ? 1.1 : 1.0)
                                .opacity(madeFTIsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        madeFTIsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        madeFTIsPressed = false
                                    }
                                }

                                
                                Button("Missed Free Throw"){
                                    game.missFT()
                                }
                                .buttonStyle(RedButton())
                                .scaleEffect(missedFTIsPressed ? 1.1 : 1.0)
                                .opacity(missedFTIsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        missedFTIsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        missedFTIsPressed = false
                                    }
                                }
                                
                            } // end HStack Free Throws
                            HStack{
                                Button("Turn     Over"){
                                    game.turnover()
                                }
                                .buttonStyle(RedButton())
                                .scaleEffect(turnoverIsPressed ? 1.1 : 1.0)
                                .opacity(turnoverIsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        turnoverIsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        turnoverIsPressed = false
                                    }
                                }
                                
                                Button("Foul"){
                                    game.foul()
                                }
                                .buttonStyle(RedButton())
                                .scaleEffect(foulIsPressed ? 1.1 : 1.0)
                                .opacity(foulIsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        foulIsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        foulIsPressed = false
                                    }
                                }
                            }
                           

                            
                        } // end VStack for basket buttons
                        
                        
                        Divider().frame(width: 2).frame(height:deviceHeight/1.8).background(Color.black)
                        
                        // vertical stack of reb/asst/to buttons
                        VStack{
                            
                            Button("Reb"){
                                game.rebound()
                            }
                            .buttonStyle(GreenButton())
                            .scaleEffect(reboundIsPressed ? 1.1 : 1.0)
                            .opacity(reboundIsPressed ? 0.6 : 1.0).pressEvents {
                                // On press
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    reboundIsPressed = true
                                }
                            } onRelease: {
                                withAnimation {
                                    reboundIsPressed = false
                                }
                            }

                            
                            
                            Button("Assist"){
                                game.assist()
                            }
                            .buttonStyle(GreenButton())
                            .scaleEffect(assistIsPressed ? 1.1 : 1.0)
                            .opacity(assistIsPressed ? 0.6 : 1.0).pressEvents {
                                // On press
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    assistIsPressed = true
                                }
                            } onRelease: {
                                withAnimation {
                                    assistIsPressed = false
                                }
                            }

                            
                            Button("Steal"){
                                game.steal()
                            }
                            .buttonStyle(GreenButton())
                            .scaleEffect(stealIsPressed ? 1.1 : 1.0)
                            .opacity(stealIsPressed ? 0.6 : 1.0).pressEvents {
                                // On press
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    stealIsPressed = true
                                }
                            } onRelease: {
                                withAnimation {
                                    stealIsPressed = false
                                }
                            }

                            Button("Block"){
                                game.block()
                            }
                            .buttonStyle(GreenButton())
                            .scaleEffect(blockIsPressed ? 1.1 : 1.0)
                            .opacity(blockIsPressed ? 0.6 : 1.0).pressEvents {
                                // On press
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    blockIsPressed = true
                                }
                            } onRelease: {
                                withAnimation {
                                    blockIsPressed = false
                                }
                            }
                            
                        } // end VStack of Reb, Asst, Stl, Blocks
                    } // end top HStack with basket buttons, reb/asst/to, divider buttons
                } // end regular button VStack
            } // end if !showFix
                
            // if fix toggle is on, show the fix buttons
            if showFix {
                
            // Fixing button VStack
                VStack{
                    
                    // HStack the basket buttons with the divider and reb/asst/to buttons
                    HStack{
                        
                        // Basket buttons
                        VStack{
                            
                            // 2-pointers
                            HStack{
                                Button("Undo Made 2"){
                                    game.removeMakeTwo()
                                }
                                .buttonStyle(GreenButton())
                                .scaleEffect(undomade2IsPressed ? 1.1 : 1.0)
                                .opacity(undomade2IsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        undomade2IsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        undomade2IsPressed = false
                                    }
                                }
                                
                                Button("Undo  Missed     2"){
                                    game.removeMissTwo()
                                }
                                .buttonStyle(RedButton())
                                .scaleEffect(undomissed2IsPressed ? 1.1 : 1.0)
                                .opacity(undomissed2IsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        undomissed2IsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        undomissed2IsPressed = false
                                    }
                                }
                                
                            } // end Hstack 2-pointers
                            
                            // 3-pointers
                            HStack{
                                Button("Undo Made 3"){
                                    game.removeMakeThree()
                                    
                                }
                                .buttonStyle(GreenButton())
                                .scaleEffect(undomade3IsPressed ? 1.1 : 1.0)
                                .opacity(undomade3IsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        undomade3IsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        undomade3IsPressed = false
                                    }
                                }

                                
                                Button("Undo   Missed     3"){
                                    game.removeMissThree()
                                }
                                .buttonStyle(RedButton())
                                .scaleEffect(undomissed3IsPressed ? 1.1 : 1.0)
                                .opacity(undomissed3IsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        undomissed3IsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        undomissed3IsPressed = false
                                    }
                                }

                                
                            } // end Hstack 3 pters
                            
                            // Free Throws
                            HStack{
                                Button("Undo Made      FT"){
                                    game.removeMakeFT()
                                }
                                .buttonStyle(GreenButton())
                                .scaleEffect(undomadeFTIsPressed ? 1.1 : 1.0)
                                .opacity(undomadeFTIsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        undomadeFTIsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        undomadeFTIsPressed = false
                                    }
                                }
                                
                                Button("Undo Missed    FT"){
                                    game.removeMissFT()
                                }
                                .buttonStyle(RedButton())
                                .scaleEffect(undomissedFTIsPressed ? 1.1 : 1.0)
                                .opacity(undomissedFTIsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        undomissedFTIsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        undomissedFTIsPressed = false
                                    }
                                }
                                
                            } // end HStack Free Throws
                            
                            HStack{
                                Button("Undo       TO"){
                                    game.removeTurnover()
                                }
                                .buttonStyle(RedButton())
                                .scaleEffect(undoturnoverIsPressed ? 1.1 : 1.0)
                                .opacity(undoturnoverIsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        undoturnoverIsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        undoturnoverIsPressed = false
                                    }
                                }
                                
                                Button("Undo       Foul"){
                                    game.removeFoul()
                                }
                                .buttonStyle(RedButton())
                                .scaleEffect(undofoulIsPressed ? 1.1 : 1.0)
                                .opacity(undofoulIsPressed ? 0.6 : 1.0).pressEvents {
                                    // On press
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        undofoulIsPressed = true
                                    }
                                } onRelease: {
                                    withAnimation {
                                        undofoulIsPressed = false
                                    }
                                }
                            }
                           
                            
                        } // end VStack for basket buttons
                        
                        
                        Divider().frame(width: 2).frame(height:deviceHeight/1.8).background(Color.black)
                        
                        // vertical stack of reb/asst/to buttons
                        VStack{
                            
                            Button("Undo     Reb"){
                                game.removeRebound()
                            }
                            .buttonStyle(GreenButton())
                            .scaleEffect(undoreboundIsPressed ? 1.1 : 1.0)
                            .opacity(undoreboundIsPressed ? 0.6 : 1.0).pressEvents {
                                // On press
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    undoreboundIsPressed = true
                                }
                            } onRelease: {
                                withAnimation {
                                    undoreboundIsPressed = false
                                }
                            }

                            
                            Button("Undo Assist"){
                                game.removeAssist()
                            }
                            .buttonStyle(GreenButton())
                            .scaleEffect(undoassistIsPressed ? 1.1 : 1.0)
                            .opacity(undoassistIsPressed ? 0.6 : 1.0).pressEvents {
                                // On press
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    undoassistIsPressed = true
                                }
                            } onRelease: {
                                withAnimation {
                                    undoassistIsPressed = false
                                }
                            }
                            
                            Button("Undo Steal"){
                                game.removeSteal()
                            }
                            .buttonStyle(GreenButton())
                            .scaleEffect(undostealIsPressed ? 1.1 : 1.0)
                            .opacity(undostealIsPressed ? 0.6 : 1.0).pressEvents {
                                // On press
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    undostealIsPressed = true
                                }
                            } onRelease: {
                                withAnimation {
                                    undostealIsPressed = false
                                }
                            }
                            
                            Button("Undo       Block"){
                                game.removeBlock()
                            }
                            .buttonStyle(GreenButton())
                            .scaleEffect(undoblockIsPressed ? 1.1 : 1.0)
                            .opacity(undoblockIsPressed ? 0.6 : 1.0).pressEvents {
                                // On press
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    undoblockIsPressed = true
                                }
                            } onRelease: {
                                withAnimation {
                                    undoblockIsPressed = false
                                }
                            }
                            
                        } // end VStack of Reb, Asst, Stl, TO
                    } // end top HStack with basket buttons, reb/asst/to, divider buttons
                } // end regular button VStack
            } // end if showFix
            Spacer()

            HStack(spacing: 20) { // Add spacing between Fix and Reset

                // Toggle button for Fix
                Toggle(isOn: $showFix) {
                    Text("Fix")
                        .font(.system(size: deviceHeight / 770 * 25, weight: .bold))
                        .minimumScaleFactor(0.5) // Allows shrinking
                        .lineLimit(1) // Ensures single line
                        .frame(width: 100, height: 40) // Fixed size for uniformity
                        .foregroundColor(.white)
                        .background(showFix ? Color.blue : Color.gray) // Change color based on state
                        .clipShape(Capsule()) // Rounded button
                        .overlay(
                            Capsule().stroke(Color.blue, lineWidth: 2) // Outline
                        )
                }
                .toggleStyle(.button)

                // Reset Button
                NavigationLink(destination: ResetView().navigationBarBackButtonHidden(true)) {
                    Text("Reset")
                        .font(.system(size: deviceHeight / 770 * 25, weight: .bold))
                        .minimumScaleFactor(0.5) // Allows shrinking
                        .lineLimit(1) // Ensures single line
                        .frame(width: 100, height: 40) //
                        .foregroundColor(.white)
                        .background(Color.red) // Red for emphasis
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.red.opacity(0.8), lineWidth: 2)
                        )
                }

            } // end HStack
            .padding(.vertical, 10)
            
            BannerAdView(adFormat: UIDevice.current.userInterfaceIdiom == .pad ? .leaderboard : .standardBanner, onShow: { print("Show Banner") })
                .padding(.bottom, 10)
            }// end VStack for screeen
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            requestPermission()
                        }
                    })
        .navigationTitle("")
        } // end Navigation View
    } // end var body
} // end struct


struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }  // end some View
} // end struct Preview
