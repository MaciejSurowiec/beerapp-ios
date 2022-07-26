//
//  LoginView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 05/06/2022.
//

import SwiftUI

import BCrypt

struct LoginView: View {
    enum Field: Hashable {
        case loginField
        case passField
    }
    @EnvironmentObject var modelData: ModelData
    
    
    @State private var login: String  = ""
    @State private var pass: String  = ""
    
    @State private var emptyLoginE: Bool = false
    @State private var emptyPassE: Bool = false
    
    @State private var wrongPassLogE: Bool = false
   
    @FocusState private var focusField: Field?
    
    func buttAction (sender:UIButton) {
        modelData.unloggedPage = ModelData.UnloggPages.start
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack{
                if modelData.isGettingPassword {
                    ProgressView().scaleEffect(3)
                }
                    Spacer()
                }
                
               VStack{
                   if(wrongPassLogE) {
                       Text("błędny login lub hasło")
                           .fontWeight(.light)
                           .foregroundColor(Color.red)
                   }
                   
                   HStack{
                       TextField("Login", text: $login, onCommit: {
                           wrongPassLogE = false
                           emptyLoginE = login.isEmpty
                           focusField = .passField
                   }).submitLabel(.next)
                           .disableAutocorrection(true)
                           .autocapitalization(.none)
                           .textContentType(.nickname)
                       
                   }.focused($focusField, equals: .loginField)
                       .padding()
                       .overlay(RoundedRectangle(cornerRadius: 8).stroke(focusField == .loginField ? Color.chocolate : .white.opacity(0),lineWidth: 1 ))

                   if(emptyLoginE) {
                       Text("brak danych")
                           .fontWeight(.light)
                           .foregroundColor(Color.red)
                   }
                   
                   HStack{
                       SecureField("Hasło", text: $pass, onCommit: {
                           emptyPassE = pass.isEmpty
                           wrongPassLogE = false
                           Login()
                       })
                           .disableAutocorrection(true)
                           .autocapitalization(.none)
                           .textContentType(.newPassword)
                           .submitLabel(.done)
                   }.focused($focusField, equals: .passField)
                       .padding()
                       .submitLabel(.next).overlay(RoundedRectangle(cornerRadius: 8).stroke(focusField == .passField ? Color.chocolate : .white.opacity(0),lineWidth: 1 ))
                        
                   if(emptyPassE) {
                       Text("brak danych")
                           .fontWeight(.light)
                           .foregroundColor(Color.red)
                   }
                   Spacer()
                   Button("Zaloguj") {
                       Login()
                   }.buttonStyle(.borderedProminent)
                       .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xxxLarge/*@END_MENU_TOKEN@*/)
                       .padding(.bottom, 50)
                       .disabled(login.isEmpty || pass.isEmpty || modelData.isGettingPassword)
                   Spacer()
                   VStack{
                       Text("Nie masz konta?")
                       NavigationLink("Zarejestruj się", destination: RegisterView())
                           .dynamicTypeSize(.large)
                       Spacer()
                   }
                   
                }
                .padding()
                .navigationTitle("Logowanie")
                .disabled(modelData.isGettingPassword)
            }
        }
    }
    
    func Login(){
        if(!emptyPassE && !emptyLoginE) {
            modelData.GetPassword(login: login, callback: CheckPassword)
        } else{
            print("blocked")
        }
    }
    
    func CheckPassword(_ hashed: String) {
        if hashed.isEmpty {
            wrongPassLogE = true
        } else {
            if (BCrypt.Check(pass, hashed: hashed)) {
                modelData.OnLogin(login)
            } else {
                wrongPassLogE = true
                print("bledne haslo")
            }
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(ModelData())
    }
}
