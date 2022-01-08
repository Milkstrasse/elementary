//
//  OptionsView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct SettingsView: View {
    @Binding var settingsToggle: Bool
    @Binding var offsetX: CGFloat
    
    @State var langIndex: Int = 0
    
    func getCurrentLang() -> Int {
        for index in GlobalData.shared.languages.indices {
            if GlobalData.shared.currentLang == GlobalData.shared.languages[index] {
                return index
            }
        }
        
        return 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                HStack(spacing: 0) {
                    Spacer()
                    Triangle().fill(Color.pink).frame(width: 134)
                    Rectangle().fill(Color.pink).frame(width: 315 + geometry.safeAreaInsets.trailing)
                }
                .offset(x: geometry.safeAreaInsets.trailing)
                VStack(alignment: .leading, spacing: 0) {
                    CustomText(key: "settings").frame(height: 60).padding([.top, .leading], 15)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 40)
                                HStack {
                                    CustomText(key: "Option").frame(width: 100, alignment: .leading)
                                    Button("<") {
                                    }
                                    .buttonStyle(ClearGrowingButton(width: 40, height: 40))
                                    Spacer()
                                    CustomText(text: "100%")
                                    Spacer()
                                    Button(">") {
                                    }
                                    .buttonStyle(ClearGrowingButton(width: 40, height: 40))
                                }
                                .padding(.horizontal, 15)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 40)
                                HStack {
                                    CustomText(key: "Option").frame(width: 100, alignment: .leading)
                                    Button("<") {
                                    }
                                    .buttonStyle(ClearGrowingButton(width: 40, height: 40))
                                    Spacer()
                                    CustomText(text: "100%")
                                    Spacer()
                                    Button(">") {
                                    }
                                    .buttonStyle(ClearGrowingButton(width: 40, height: 40))
                                }
                                .padding(.horizontal, 15)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 40)
                                HStack {
                                    CustomText(key: "Option").frame(width: 100, alignment: .leading)
                                    Button("<") {
                                        if langIndex <= 0 {
                                            langIndex = GlobalData.shared.languages.count - 1
                                        } else {
                                            langIndex -= 1
                                        }
                                        
                                        GlobalData.shared.loadLanguage(language: GlobalData.shared.languages[langIndex])
                                    }
                                    .buttonStyle(ClearGrowingButton(width: 40, height: 40))
                                    Spacer()
                                    CustomText(key: GlobalData.shared.languages[langIndex])
                                    Spacer()
                                    Button(">") {
                                        if langIndex >= GlobalData.shared.languages.count - 1 {
                                            langIndex = 0
                                        } else {
                                            langIndex += 1
                                        }
                                        
                                        GlobalData.shared.loadLanguage(language: GlobalData.shared.languages[langIndex])
                                    }
                                    .buttonStyle(ClearGrowingButton(width: 40, height: 40))
                                }
                                .padding(.horizontal, 15)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    Spacer().frame(height: 10)
                    HStack(spacing: 5) {
                        Spacer()
                        Button(GlobalData.shared.getTranslation(key: "reset")) {
                            GlobalData.shared.loadLanguage(language: String(Locale.preferredLanguages[0].prefix(2)))
                            langIndex = getCurrentLang()
                        }
                        .buttonStyle(GrowingButton(width: 160))
                        Button("X") {
                            UserDefaults.standard.set(GlobalData.shared.languages[langIndex], forKey: "lang")
                            offsetX = -449
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                settingsToggle = false
                            }
                        }
                        .buttonStyle(GrowingButton(width: 40))
                    }
                    .padding(.trailing, 15)
                }
                .frame(width: 340).padding(.vertical, 15)
            }
            .padding(.trailing, offsetX).animation(.linear(duration: 0.2), value: offsetX).edgesIgnoringSafeArea(.bottom)

        }
        .onAppear {
            offsetX = 0
            
            langIndex = getCurrentLang()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsToggle: Binding.constant(true), offsetX: Binding.constant(0))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
