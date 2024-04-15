//
//  CheckoutView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-10.
//

import SwiftUI
import Stripe

struct CheckoutView: View {
    @ObservedObject var basketItemsViewModel: BasketItemsViewModel
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var name: String = ""
    @State private var streetAddress: String = ""
    @State private var city: String = ""
    @State private var zipCode: String = ""
    @State private var country: String = ""
    
    @State private var showingPlaceOrderError = false
    @State private var invalidFields: Set<String> = []
    @State private var showingPaymentSheet = false
    @State private var showingConfirmation = false

    
    var body: some View {
      //  NavigationView{
            Form {
                Section(header: Text("Shipping Address")) {
                    TextField("Name", text: $name)
                        if showingPlaceOrderError && invalidFields.contains("Name") {
                            Text("Please provide Name")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    TextField("Street Address", text: $streetAddress)
                        if showingPlaceOrderError && invalidFields.contains("Street Address") {
                            Text("Please provide your Street Address")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    TextField("City", text: $city)
                        if showingPlaceOrderError && invalidFields.contains("City") {
                            Text("Please provide your City")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    TextField("Zip Code", text: $zipCode)
                        if showingPlaceOrderError && invalidFields.contains("Zip Code") {
                            Text("Please provide your Zip Code")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    TextField("Country", text: $country)
                        if showingPlaceOrderError && invalidFields.contains("Country") {
                            Text("Please provide your Country")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                }
                
                Section {
                    ForEach(basketItemsViewModel.basketItems) { item in
                        HStack {
                            Text(item.name )
                            Spacer()
                            Text("\(item.quantity ?? 0)x")
                            Text("$\(item.price ?? 0.0, specifier: "%.2f")")
                        }
                    }
                }
                
                Section(header: Text("Total")) {
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Subtotal: $\(basketItemsViewModel.totalPrice, specifier: "%.2f")")
                                .padding(.vertical, 2)
                            Text("GST (5%): $\(basketItemsViewModel.gst, specifier: "%.2f")")
                                .padding(.vertical, 2)
                            Text("QST (9.975%): $\(basketItemsViewModel.qst, specifier: "%.2f")")
                            Divider()
                            Text("Total: $\(basketItemsViewModel.totalWithTaxes, specifier: "%.2f")")
                                .font(.title)
                        }
                    }
                }

                Button("Continue to paiment") {
                    saveAddress()
                }
                .disabled(basketItemsViewModel.basketItems.isEmpty)
            }
            .navigationTitle("Checkout")
            .sheet(isPresented: $showingPaymentSheet) {
                PaymentView(basketItemsViewModel: basketItemsViewModel).environmentObject(viewRouter)
                    }
            .navigationBarTitleDisplayMode(.inline)
            
      //  }
    }
    
    private func saveAddress() {
        if validateFields() {
            showingPlaceOrderError = false
            let addressData: [String: Any] = [
                "name": name,
                "streetAddress": streetAddress,
                "city": city,
                "zipCode": zipCode,
                "country": country
            ]
            createPaymentIntent(totalPrice: Int(basketItemsViewModel.totalWithTaxes * 100))
            guard let userId = basketItemsViewModel.authViewModel.currentUser?.id else {
                print("Error: User ID is nil")
                return
            }
            basketItemsViewModel.saveAddressForUser(userId: userId, address: addressData) { success, error in
                if success {
                    print("Address saved successfully")
                } else {
                    // Handle the error scenario, perhaps by showing an alert to the user
                    if let error = error {
                        print("Error saving address: \(error.localizedDescription)")
                    } else {
                        print("Unknown error saving address")
                    }
                }
            }
        } else{
            showingPlaceOrderError = true
        }
        showingPaymentSheet = true
    }

    // Add this function in your CheckoutView
    private func createPaymentIntent(totalPrice: Int) {
        // Convert the total price to the smallest currency unit
        let priceInCents = totalPrice * 100
        
        // Your server endpoint URL
        let url = URL(string: "https://candle-spiced-angelfish.glitch.me/create-payment-intent")!
        
        // Create the URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Set the request body
        let json: [String: Any] = ["totalPrice": totalPrice]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let clientSecret = jsonResponse["clientSecret"] as? String else {
                print("Invalid response from server.")
                return
            }
            
            print("Received client secret: \(clientSecret)")
            
            PaymentConfig.shared.paymentIntentClientSecret = clientSecret
            
        }.resume()
    }

    
    private func validateFields() -> Bool {
        invalidFields.removeAll()

        if name.isEmpty { invalidFields.insert("Name") }
        if streetAddress.isEmpty { invalidFields.insert("Street Address") }
        if city.isEmpty { invalidFields.insert("City") }
        if zipCode.isEmpty { invalidFields.insert("Zip Code") }
        if country.isEmpty { invalidFields.insert("Country") }

        return invalidFields.isEmpty
    }
}
    

    


struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAuthViewModel = AuthViewModel()
        let mockBasketItemsViewModel = BasketItemsViewModel(authViewModel: mockAuthViewModel)
        
        CheckoutView(basketItemsViewModel: mockBasketItemsViewModel)
    }
}

