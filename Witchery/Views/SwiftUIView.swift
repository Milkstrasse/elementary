//
//  SwiftUIView.swift
//  Witchery
//
//  Created by Janice Hablützel on 23.07.22.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                Color.red
                ZStack(alignment: .top) {
                    Rectangle().fill(Color.yellow)
                    Text("Hallo").frame(height: 355)
                }
                .frame(height: 355).padding(.top, 312)
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
