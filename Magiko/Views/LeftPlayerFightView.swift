//
//  LeftPlayerFightView.swift
//  Magiko
//
//  Created by Janice Hablützel on 04.01.22.
//

import SwiftUI

struct LeftPlayerFightView: View {
    var offsetX: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                ZStack(alignment: .topLeading) {
                    Image("magicalgirl_1").resizable().scaleEffect(3.7).aspectRatio(contentMode: .fit).frame(width: 215).offset(x: -40 + offsetX, y: 0).rotationEffect(.degrees(90)).animation(.easeOut(duration: 0.3), value: offsetX)
                    Rectangle().fill(Color.yellow).frame(width: 175 + geometry.safeAreaInsets.leading).offset(x: -geometry.safeAreaInsets.leading)
                    HStack(spacing: 0) {
                        Text("Action!!!").frame(width: 142)
                        VStack(alignment: .leading) {
                            Text("Next")
                            Spacer()
                            ZStack(alignment: .leading) {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 4) {
                                        Circle().fill(Color.blue).frame(width: 12)
                                        Circle().fill(Color.blue).frame(width: 12)
                                        Circle().fill(Color.blue).frame(width: 12)
                                        Circle().fill(Color.blue).frame(width: 12)
                                    }
                                    .padding(.leading, 24)
                                    HStack(spacing: 0) {
                                        Triangle().fill(Color.blue).frame(width: 20)
                                        ZStack(alignment: .topTrailing) {
                                            Rectangle().fill(Color.blue).frame(width: 210)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5).fill(Color.green)
                                                Text("Fine")
                                            }
                                            .frame(width: 90, height: 30).offset(x: -15, y: -15)
                                            VStack(spacing: 0) {
                                                HStack {
                                                    Text("Nickname")
                                                    Spacer()
                                                    Text("100/100HP")
                                                }
                                                Rectangle().fill(Color.purple).frame(height: 6)
                                            }
                                            .padding(.horizontal, 15).frame(height: 55)
                                        }
                                    }
                                    .frame(height: 55)
                                }
                                .frame(height: 75)
                            }
                            .rotationEffect(.degrees(90)).frame(width: 75, height: 230).offset(y: -offsetX).animation(.easeOut(duration: 0.3).delay(0.1), value: offsetX)
                        }
                    }
                }
                .frame(width: 215)
                Spacer()
            }
        }
    }
}

struct LeftPlayerFightView_Previews: PreviewProvider {
    static var previews: some View {
        LeftPlayerFightView(offsetX: 0).edgesIgnoringSafeArea(.bottom)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
