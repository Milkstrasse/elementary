//
//  OverviewView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct OverviewView: View {
    @State var fighterSelected: Bool = false
    @State var infoToggle: Bool = false
    
    @Binding var currentFighter: String
    
    @Binding var overviewToggle: Bool
    @Binding var offsetX: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if fighterSelected {
                    HStack(alignment: .top) {
                        Button(infoToggle ? "X" : "?") {
                            infoToggle = !infoToggle
                        }
                        .buttonStyle(GrowingButton(width: 40))
                        Spacer()
                        ZStack {
                            Color.red
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Nickname")
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: 5) {
                                        StatOverviewView().padding(.bottom, 5)
                                        DetailedAttackView()
                                        DetailedAttackView()
                                        DetailedAttackView()
                                    }
                                }
                            }
                        }
                        .frame(width: 345).offset(x: infoToggle ? 0 : 224).animation(.linear(duration: 0.2), value: infoToggle)
                    }
                    .padding(.all, 15)
                }
                ZStack(alignment: .trailing) {
                    HStack(spacing: 0) {
                        Spacer()
                        Triangle().fill(Color.pink).frame(width: 134)
                        Rectangle().fill(Color.pink).frame(width: 315 + geometry.safeAreaInsets.trailing)
                    }
                    .offset(x: geometry.safeAreaInsets.trailing)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Overview").frame(height: 60).padding([.top, .leading], 15)
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    RectangleFighterView(isSelected: false).onTapGesture {
                                        fighterSelected = true
                                        currentFighter = "magicalgirl_2"
                                    }
                                    RectangleFighterView(isSelected: false).onTapGesture {
                                        fighterSelected = true
                                        currentFighter = "magicalgirl_2"
                                    }
                                    RectangleFighterView(isSelected: false).onTapGesture {
                                        fighterSelected = true
                                        currentFighter = "magicalgirl_2"
                                    }
                                }
                                HStack(spacing: 8) {
                                    RectangleFighterView(isSelected: false).onTapGesture {
                                        fighterSelected = true
                                        currentFighter = "magicalgirl_2"
                                    }
                                    RectangleFighterView(isSelected: false).onTapGesture {
                                        fighterSelected = true
                                        currentFighter = "magicalgirl_2"
                                    }
                                    RectangleFighterView(isSelected: false).onTapGesture {
                                        fighterSelected = true
                                        currentFighter = "magicalgirl_2"
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                        }
                        Spacer().frame(height: 10)
                        HStack(spacing: 5) {
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: 160, height: 40)
                                HStack {
                                    Button("<") {
                                        print("Button pressed!")
                                    }
                                    Spacer()
                                    Text("All Types")
                                    Spacer()
                                    Button(">") {
                                        print("Button pressed!")
                                    }
                                }
                                .frame(width: 130).padding(.horizontal, 15)
                            }
                            Button("X") {
                                fighterSelected = false
                                offsetX = -449
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    overviewToggle = false
                                }
                            }
                            .buttonStyle(GrowingButton(width: 40))
                        }
                        .padding(.trailing, 15)
                    }
                    .frame(width: 340).padding(.vertical, 15)
                }
                .padding(.trailing, offsetX).animation(.linear(duration: 0.2), value: offsetX).offset(x: infoToggle ? 449 : 0).animation(.linear(duration: 0.2), value: infoToggle)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            offsetX = 0
        }
    }
}

struct RectangleFighterView: View {
    var isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 5).fill(isSelected ? Color.yellow : Color.blue).frame(height: 125)
            Image("magicalgirl_2").resizable().scaleEffect(4.6).aspectRatio(contentMode: .fit).frame(height: 125).offset(y: 100).clipShape(RoundedRectangle(cornerRadius: 5))
            Triangle().fill(Color.green).frame(height: 35).padding(.bottom, 10)
            Rectangle().fill(Color.green).frame(height: 5).padding(.bottom, 5)
            RoundedRectangle(cornerRadius: 5).fill(Color.green).frame(height: 10)
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(currentFighter: Binding.constant("magicalgirl_1"), overviewToggle: Binding.constant(true), offsetX: Binding.constant(0))
.previewInterfaceOrientation(.landscapeLeft)
    }
}

struct DetailedAttackView: View {
    var width: CGFloat?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(Color.yellow)
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text("Attack")
                    Text("Description")
                }
                .padding(.leading, 15)
                Spacer()
                Triangle().fill(Color.green).frame(width: 22)
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.green).frame(width: 25)
                    RoundedRectangle(cornerRadius: 5).fill(Color.green).frame(width: 55)
                }
            }
        }
        .frame(width: width, height: 60)
    }
}

struct StatOverviewView: View {
    var width: CGFloat?
    
    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 75)
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Stat")
                            Spacer()
                            Text("100")
                        }
                        HStack {
                            Text("Stat")
                            Spacer()
                            Text("100")
                        }
                        HStack {
                            Text("Stat")
                            Spacer()
                            Text("100")
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 75)
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Stat")
                            Spacer()
                            Text("100")
                        }
                        HStack {
                            Text("Stat")
                            Spacer()
                            Text("100")
                        }
                        HStack {
                            Text("Stat")
                            Spacer()
                            Text("100")
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .frame(width: width)
    }
}
