//
//  BottomTextView.swift
//  BBallStats
//
//  Created by Chad Wallace on 10/27/22.
//

import SwiftUI

struct BottomTextView: View {
    
    let text: String
    
    var body: some View {
        HStack{
            Spacer()
            Text(text)
                .font(.title3)
                .bold()
                .padding()
            Spacer()
        }.background(Color.blue)
        .foregroundColor(Color.white)
        
    }
}

struct BottomTextView_Previews: PreviewProvider {
    static var previews: some View {
        BottomTextView(text: "Okay, Let's Go!")
    }
}
