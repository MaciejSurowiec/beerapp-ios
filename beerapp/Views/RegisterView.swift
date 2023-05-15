//
//  RegisterView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 09/06/2022.
//

import SwiftUI
import BCrypt

struct RegisterView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    enum Field: Hashable {
        case loginField
        case emailField
        case passField
        case pass2Field
    }
    
    @State private var login: String  = ""
    @State private var email: String  = ""
    @State private var pass: String  = ""
    @State private var pass2: String  = ""
    
    @State private var unmatchedPassE = false
    
    @State private var emptyLoginE = false
    @State private var emptyEmailE = false
    @State private var emptyPassE = false
    @State private var emptyPass2E = false
    
    @State private var invalidEmailE = false
    @State private var usedLoginE = false
    @State private var weakPassE = false
    
    @State private var takenLoginE = false
    @State private var internalE = false
    @State private var internalJsonE = false
    @FocusState private var focusField: Field?
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    if modelData.isRegistrationGoing {
                        ProgressView().scaleEffect(3)
                        Spacer()
                    }
                }
            
                VStack {
                    Group{
                        if takenLoginE {
                            Text("Podany login jest już zajęty")
                                .fontWeight(.light)
                                .foregroundColor(Color.red)
                        }
                        
                        if internalE {
                            Text("Blad wewnętrzny sprobój ponownie później")
                                .fontWeight(.light)
                                .foregroundColor(Color.red)
                        }
                        
                        if internalJsonE {
                            Text("Blad wewnętrzny związany z jsonem sprobój ponownie później")
                                .fontWeight(.light)
                                .foregroundColor(Color.red)
                        }
                    }
                    
                    HStack {
                        TextField("Login", text: $login, onCommit: {
                                emptyLoginE = login.isEmpty
                                focusField = .emailField
                        }).submitLabel(.next)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .textContentType(.nickname)
                    }
                    .focused($focusField, equals: .loginField)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(focusField == .loginField ? Color.chocolate : .white.opacity(0),lineWidth: 1 ))
                        
                    if emptyLoginE {
                        Text("brak danych")
                            .fontWeight(.light)
                            .foregroundColor(Color.red)
                    }
                    
                    HStack {
                        TextField("Email", text: $email, onCommit: {
                            invalidEmailE = false
                            focusField = .passField
                        }).keyboardType(.emailAddress)
                            .submitLabel(.next)
                            .textContentType(.emailAddress)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    .focused($focusField, equals: .emailField)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(focusField == .emailField ? Color.chocolate : .white.opacity(0),lineWidth: 1 ))
                    
                    if invalidEmailE {
                        Text("To nie jest poprawny email")
                            .fontWeight(.light)
                            .foregroundColor(Color.red)
                    }
                    
                    Group {
                        HStack {
                            SecureField("Hasło", text: $pass, onCommit: {
                                focusField = .pass2Field
                            })
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .textContentType(.newPassword)
                            .submitLabel(.next)
                        }
                        .focused($focusField, equals: .passField)
                        .padding()
                        .submitLabel(.next).overlay(RoundedRectangle(cornerRadius: 8).stroke(focusField == .passField ? Color.chocolate : .white.opacity(0),lineWidth: 1 ))
          
                        if weakPassE {
                            Text("hasła powinno zawierać 8 lub wiecej symboli")
                                .fontWeight(.light)
                                .foregroundColor(Color.red)
                        }
                        
                        HStack{
                            SecureField("Powtórz hasło", text: $pass2, onCommit:{
                                Register()
                            })
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .submitLabel(.done)
                            .textContentType(.newPassword)
                        }
                        .focused($focusField, equals: .pass2Field)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(focusField == .pass2Field ? Color.chocolate : .white.opacity(0),lineWidth: 1 ))
                                
                        if unmatchedPassE {
                            Text("hasła są różne")
                                .fontWeight(.light)
                                .foregroundColor(Color.red)
                        }
                    }
                    
                    Spacer()
                    Button("Rejestracja"){
                        Register()
                    }
                    .buttonStyle(.borderedProminent)
                    .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xxxLarge/*@END_MENU_TOKEN@*/)
                    .padding(.bottom,20)
                    Spacer()
                }.padding()
            }
            .navigationTitle("Rejestracja")
            .disabled(modelData.isRegistrationGoing)
        }
        .navigationBarBackButtonHidden(modelData.isRegistrationGoing)
    }
    
    func Register() {
        if login.isEmpty {
            emptyLoginE = true
        }
        
        if email.isEmpty {
            emptyEmailE = true
        } else {
            invalidEmailE = false
        }
        
        if pass.isEmpty {
            emptyPassE = true
        } else {
            if pass.count < 8 {
                weakPassE = true
            } else {
                weakPassE = false
            }
        }
        
        if pass2.isEmpty {
            emptyPass2E = true
        }
        
        if !emptyLoginE && !emptyEmailE && !emptyPassE && !emptyPass2E && !invalidEmailE && !weakPassE {
            if !unmatchedPassE {
                takenLoginE = false
                internalE = false
                internalJsonE = false
                do {
                    let salt = try BCrypt.Salt()
                    let hashed = try BCrypt.Hash(pass,salt:salt)
                    modelData.Register(login: login, email: email, password: hashed, callback: RegisterResult)
                } catch {
                    print("Bcrypt gone wrong")
                }
            }
        }
    }
    
    func RegisterResult(_ code: Int) {
        switch code {
            case 204:
                    modelData.OnLogin(login)
            case 400:
                usedLoginE = true
            case 409:
                internalJsonE = true
            case 500:
                internalE = true
            default:
                internalE = true
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView().environmentObject(ModelData())
    }
}
