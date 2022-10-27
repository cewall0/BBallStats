//
//  DownButton.swift
//  BBallStats
//
//  Created by Chad Wallace on 10/27/22.
//

import SwiftUI

struct DownButton: View {
    var number : Int
    
    var body: some View {
        Text("\(number)")
            .frame(width: 110, height: 110)
            .font(.system(size: 40, weight: .bold))
            .foregroundColor(Color.white)
            .background(Color.red)
            .clipShape(Circle())
            .padding()
    }
}

struct DownButton_Previews: PreviewProvider {
    static var previews: some View {
        DownButton(number: 100)
    }
}

