//
//  UpButton.swift
//  BBallStats
//
//  Created by Chad Wallace on 10/26/22.
//

import SwiftUI

struct UpButton: View {
    var number : Int
    
    var body: some View {
        Text("\(number)")
            .frame(width: 110, height: 110)
            .font(.system(size: 40, weight: .bold))
            .foregroundColor(Color.white)
            .background(Color.green)
            .clipShape(Circle())
            .padding()
    }
}

struct UpButton_Previews: PreviewProvider {
    static var previews: some View {
        UpButton(number: 100)
    }
}
