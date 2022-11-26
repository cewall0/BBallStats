//
//  GameView.swift
//  BBallStats
//
//  Created by Chad Wallace on 10/21/22.
//

import SwiftUI

struct GameView: View {

    @EnvironmentObject var game: Game
    @State private var showFix = false
    
    // Style information for Green button
    struct GreenButton: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: 110, height: 110)
                .multilineTextAlignment(.center)
                .font(.system(size: 22, weight: .bold))
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
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: 110, height: 110)
                .multilineTextAlignment(.center)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.white)
                .background(Color(UIColor(red:178/255, green: 34/255, blue: 34/255, alpha: 1.0)))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 4))
                .padding(.leading,3)
                .padding(.bottom,3)
                .padding(.trailing,3)
        }
    }
    // This is the Game View
    var body: some View {
        NavigationStack{
            
            // vertical the whole GameView screeen
        VStack {
            
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
                                
                                Button("Missed 2 pt"){
                                    game.missTwo()
                                }
                                .buttonStyle(RedButton())
                                
                            } // end Hstack 2-pointers
                            
                            // 3-pointers
                            HStack{
                                Button("Made   3 pt"){
                                    game.makeThree()
                                }
                                .buttonStyle(GreenButton())

                                
                                Button("Missed 3 pt"){
                                    game.missThree()
                                }
                                .buttonStyle(RedButton())
                                
                            } // end Hstack 3 pters
                            
                            // Free Throws
                            HStack{
                                Button("Made    Free Throw"){
                                    game.makeFT()
                                }
                                .buttonStyle(GreenButton())

                                
                                Button("Missed Free Throw"){
                                    game.missFT()
                                }
                                .buttonStyle(RedButton())
                                
                            } // end HStack Free Throws
                            
                            Button("Turn     Over"){
                                game.turnover()
                            }
                            .buttonStyle(RedButton())
                            
                        } // end VStack for basket buttons
                        
                        
                        Divider().frame(width: 2).frame(height:400).background(Color.black)
                        
                        // vertical stack of reb/asst/to buttons
                        VStack{
                            
                            Button("Reb"){
                                game.rebound()
                            }
                            .buttonStyle(GreenButton())

                            
                            
                            Button("Assist"){
                                game.assist()
                            }
                            .buttonStyle(GreenButton())

                            
                            Button("Steal"){
                                game.steal()
                            }
                            .buttonStyle(GreenButton())

                            Button("Block"){
                                game.block()
                            }
                            .buttonStyle(GreenButton())
                            
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
                                
                                Button("Undo  Missed     2"){
                                    game.removeMissTwo()
                                }
                                .buttonStyle(RedButton())
                                
                            } // end Hstack 2-pointers
                            
                            // 3-pointers
                            HStack{
                                Button("Undo Made 3"){
                                    game.removeMakeThree()
                                }
                                .buttonStyle(GreenButton())
                                
                                Button("Undo   Missed     3"){
                                    game.removeMissThree()
                                }
                                .buttonStyle(RedButton())
                                
                            } // end Hstack 3 pters
                            
                            // Free Throws
                            HStack{
                                Button("Undo Made      FT"){
                                    game.removeMakeFT()
                                }
                                .buttonStyle(GreenButton())
                                
                                Button("Undo Missed    FT"){
                                    game.removeMissFT()
                                }
                                .buttonStyle(RedButton())
                                
                            } // end HStack Free Throws
                            
                            Button("Undo       TO"){
                                game.removeTurnover()
                            }
                            .buttonStyle(RedButton())
                            
                        } // end VStack for basket buttons
                        
                        
                        Divider().frame(width: 2).frame(height:400).background(Color.black)
                        
                        // vertical stack of reb/asst/to buttons
                        VStack{
                            
                            Button("Undo     Reb"){
                                game.removeRebound()
                            }
                            .buttonStyle(GreenButton())

                            
                            Button("Undo Assist"){
                                game.removeAssist()
                            }
                            .buttonStyle(GreenButton())
                            
                            Button("Undo Steal"){
                                game.removeSteal()
                            }
                            .buttonStyle(GreenButton())
                            
                            Button("Undo       Block"){
                                game.removeBlock()
                            }
                            .buttonStyle(GreenButton())
                            
                        } // end VStack of Reb, Asst, Stl, TO
                    } // end top HStack with basket buttons, reb/asst/to, divider buttons
                } // end regular button VStack
            } // end if showFix
              
            HStack{
                // Toggle button to turn on if we need to fix a stat.
                Toggle("Fix", isOn: $showFix)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
                    .tint(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
                    .toggleStyle(.button)
//                    .padding()
                
                
            } // end HStack
            

                StatsView(game: game)
            
//            Text("          ")
            NavigationLink(
                destination: ResetView().navigationBarBackButtonHidden(true),
                label:{
                    Text("Reset")
                })
            .font(.system(size: 30, weight: .bold))
            .foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            } // end VStack for screeen
        .navigationTitle("")
        } // end Navigation View
    } // end var body
} // end struct


struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }  // end some View
} // end struct Preview
