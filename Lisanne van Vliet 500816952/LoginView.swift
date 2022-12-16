//
//  LoginView.swift
//  Lisanne van Vliet 500816952
//
//  Created by Lisanne van Vliet on 12/11/2021.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @State var username: String = ""
    @State var password: String = ""
    @State var accountExists: Bool = true
    @State var message: String = ""
    
    var isFormValid: Bool {
        return username.count >= 3 && password.count >= 3
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField("Username", text: $username)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            // If it is unknown whether the account already exists.
            if accountExists {
                Button(action: {
                    LoginAPI.shared.logIn(username: username, password: password) { result in
                        switch result {
                        case .success(let response):
                            LoginAPI.shared.accessToken = response.accessToken
                            
                            DispatchQueue.main.async {
                                self.dismiss()
                            }
                        case .failure(_):
                            accountExists = false
                            message = NSLocalizedString("Account not found.", comment: "")
                        }
                    }
                }) {
                    Text("Log in")
                }
                .frame(maxWidth: .infinity)
                .disabled(isFormValid == false)
                
                // If the account does not exist yet.
            } else {
                Button(action: {
                    LoginAPI.shared.register(username: username, password: password) { result in
                        switch result {
                        case .success(let response):
                            // If the account has been created, automatically log in.
                            if response.success == true {
                                LoginAPI.shared.logIn(username: username, password: password) { result in
                                    switch result {
                                    case .success(let response):
                                        LoginAPI.shared.accessToken = response.accessToken
                                        
                                        DispatchQueue.main.async {
                                            self.dismiss()
                                        }
                                    case .failure(let error):
                                        switch error {
                                        case .urlError(let urlError):
                                            print("\(urlError.localizedDescription)")
                                        case .decodingError(let decodingError):
                                            print("\(decodingError.localizedDescription)")
                                        case .genericError(let error):
                                            print("\(error.localizedDescription)")
                                        }
                                    }
                                }
                                // If the account already exists, automatically log in.
                            } else {
                                message = "\(response.message)."
                                
                                LoginAPI.shared.logIn(username: username, password: password) { result in
                                    switch result {
                                    case .success(let response):
                                        LoginAPI.shared.accessToken = response.accessToken
                                        
                                        DispatchQueue.main.async {
                                            self.dismiss()
                                        }
                                    case .failure(let error):
                                        switch error {
                                        case .urlError(let urlError):
                                            print("\(urlError.localizedDescription)")
                                        case .decodingError(let decodingError):
                                            print("\(decodingError.localizedDescription)")
                                        case .genericError(let error):
                                            print("\(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                        case .failure(let error):
                            switch error {
                            case .urlError(let urlError):
                                print("\(urlError.localizedDescription)")
                            case .decodingError(let decodingError):
                                print("\(decodingError.localizedDescription)")
                            case .genericError(let error):
                                print("\(error.localizedDescription)")
                            }
                        }
                    }
                }) {
                    Text("Log in / Sign up")
                }
                .frame(maxWidth: .infinity)
                .disabled(isFormValid == false)
                
                Text(message)
            }
            
            Spacer()
        }
        .navigationTitle("Log in")
        .padding(.horizontal)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                LoginView()
                    .environment(\.locale, .init(identifier: "en"))
            }
            
            NavigationView {
                LoginView()
                    .environment(\.locale, .init(identifier: "nl"))
            }
        }
    }
}
