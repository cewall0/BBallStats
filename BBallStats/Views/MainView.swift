//
//  MainView.swift
//  BBallStats
//
//  Created by Chad Wallace on 10/21/22.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack {
            VStack{
                
            HStack{
                Button("✗2"){
                    print("Minus two")
                }
                .frame(width: 110, height: 110)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color.white)
                .background(Color.red)
                .clipShape(Circle())
                .padding()
                Button("✓2"){
                    print("Plus two")
                }
                .frame(width: 110, height: 110)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color.white)
                .background(Color.green)
                .clipShape(Circle())
                .padding()
            } // end Hstack
                
            HStack{
                Button("✗3"){
                    print("Minus three")
                }
                .frame(width: 110, height: 110)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color.white)
                .background(Color.red)
                .clipShape(Circle())
                .padding()
                Button("✓3"){
                    print("Plus three")
                }
                .frame(width: 110, height: 110)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color.white)
                .background(Color.green)
                .clipShape(Circle())
                .padding()
            } // end Hstack
                
                HStack{
                    Button("✗FT"){
                        print("Minus free throw")
                    }
                    .frame(width: 110, height: 110)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color.white)
                    .background(Color.red)
                    .clipShape(Circle())
                    .padding()
                    Button("✓FT"){
                        print("Plus free throw")
                    }
                    .frame(width: 110, height: 110)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color.white)
                    .background(Color.green)
                    .clipShape(Circle())
                    .padding()
                } // end Hstack
                HStack{
                    Button("Reb"){
                        print("Plus rebound three")
                    }
                    .frame(width: 110, height: 110)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.white)
                    .background(Color.green)
                    .clipShape(Circle())
                    .padding()
                    Button("Asst"){
                        print("Plus assist")
                    }
                    .frame(width: 110, height: 110)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.white)
                    .background(Color.green)
                    .clipShape(Circle())
                    .padding()
                } // end Hstack
                HStack{
                    Button("TO"){
                        print("Turn over")
                    }
                    .frame(width: 110, height: 110)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color.white)
                    .background(Color.red)
                    .clipShape(Circle())
                    .padding()
                    
                } // end Hstack
            
            } // end VStack
            
            Spacer()
        } // end zstack
        
        
        .padding()
    } // end var body
    
    
    // functions
    func plus2()->Void{
        print("Plus two")
    } // end func plus2
    
    
} // end struct

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
