//
//  PaymentView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-13.
//

import SwiftUI
import Stripe

struct PaymentView: View {
    @ObservedObject var basketItemsViewModel: BasketItemsViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var paymentMethodParams: STPPaymentMethodParams?
    @State private var cardNumber: String = ""
    @State private var expirationDate: String = ""
    @State private var cvc: String = ""
    @State private var postalCode: String = ""
    var body: some View{
        Text("Payment Information")
                        .font(.title)
                        .padding(.top)
        Form {
                  Section(header: Text("Credit Card Details")) {
                      TextField("Card Number", text: $cardNumber)
                          .keyboardType(.numberPad)
                          .textContentType(.creditCardNumber)
                      
                      TextField("MM/YY", text: $expirationDate)
                          .keyboardType(.numberPad)
                      
                      TextField("CVC", text: $cvc)
                          .keyboardType(.numberPad)
                      
                      TextField("Postal Code", text: $postalCode)
                          .keyboardType(.numberPad)
                  }
                  
                  Button(action: {
                      self.processPaymentAndFinalizeOrder()
                  }) {
                      Text("Pay $\(basketItemsViewModel.totalWithTaxes, specifier: "%.2f")")
                  }
              }
              .navigationBarTitle("Payment", displayMode: .inline)
    }
    
    func createPaymentMethodParams() -> STPPaymentMethodParams? {
        guard let expMonth = extractMonth(from: self.expirationDate),
              let expYear = extractYear(from: self.expirationDate),
              !cardNumber.isEmpty, !cvc.isEmpty else {
            // Handle the case where the expiration date, card number, or CVC is not valid
            return nil
        }

        // Set up card parameters
        let cardParams = STPPaymentMethodCardParams()
        cardParams.number = cardNumber
        cardParams.expMonth = NSNumber(value: expMonth)
        cardParams.expYear = NSNumber(value: expYear)
        cardParams.cvc = cvc
        
        // Set up billing details, if you have them
        let billingDetails = STPPaymentMethodBillingDetails()
        billingDetails.address = STPPaymentMethodAddress() // Initialize the address
        billingDetails.address?.postalCode = self.postalCode // Set the postal code

        // Create PaymentMethod parameters
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: billingDetails, metadata: nil)
        return paymentMethodParams
    }


    func extractMonth(from expiry: String) -> UInt? {
        let components = expiry.split(separator: "/").map(String.init)
        guard components.count == 2, let month = UInt(components[0]), month >= 1, month <= 12 else {
            return nil
        }
        return month
    }

    func extractYear(from expiry: String) -> UInt? {
        let components = expiry.split(separator: "/").map(String.init)
        guard components.count == 2, let year = UInt(components[1]) else {
            return nil
        }
        
        // Adjust for year shorthand (converts '21' to '2021')
        let currentYear = UInt(Calendar.current.component(.year, from: Date()))
        let adjustedYear = year < 100 ? year + 2000 : year

        // Check if the year is not in the past
        guard adjustedYear >= currentYear else {
            return nil
        }
        
        return adjustedYear
    }

    private func finalizeOrder() {
        guard let userId = basketItemsViewModel.authViewModel.currentUser?.id else {
            print("Error: User ID is nil")
            return
        }
        // Save the basket as past purchases
        basketItemsViewModel.savePastPurchaseForUser(userId: userId, items: basketItemsViewModel.basketItems) { success, error in
            if success {
                // Once the basket is saved as past purchases, we can clear the basket
                basketItemsViewModel.removeAllItemsFromBasket(userId: userId) {
                    self.basketItemsViewModel.basketItems.removeAll()
                    self.basketItemsViewModel.totalPrice = 0
                }
                
                print("Order finalized successfully")
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                    self.viewRouter.showPaymentConfirmation = true
                    self.viewRouter.showCheckout = false
                    
                    basketItemsViewModel.paymentConfirmationMessage = "Your transaction id is \(PaymentConfig.shared.paymentIntendId)"
                }
                
            } else {
                // Handle the error scenario
                if let error = error {
                    print("Error saving past purchase: \(error.localizedDescription)")
                } else {
                    print("Unknown error saving past purchase")
                }
            }
        }
    }
    private func processPaymentAndFinalizeOrder() {
        // First, create payment method parameters from the card information
        guard let paymentMethodParams = createPaymentMethodParams() else {
            print("Error: Invalid payment method parameters")
            return
        }
        
        createAndConfirmPaymentMethod(paymentMethodParams: paymentMethodParams) { paymentSuccessful in
            if paymentSuccessful {
                // Only finalize the order if the payment is successful
                finalizeOrder()
            } else {
                print("Error: Payment failed")
                // Handle payment failure accordingly
            }
        }
    }

    private func createAndConfirmPaymentIntent(paymentMethodId: String, completion: @escaping (Bool) -> Void) {
      // The URL should point to your server's new endpoint for confirming a PaymentIntent
      let url = URL(string: "https://candle-spiced-angelfish.glitch.me/confirm-payment")!
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let totalCents = Int((basketItemsViewModel.totalWithTaxes * 100).rounded())
        
      let parameters: [String: Any] = [
          "paymentMethodId": paymentMethodId,
          "amount": totalCents // Convert dollars to cents
          
      ]
        
    

      request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

      // Perform the network request
      URLSession.shared.dataTask(with: request) { data, response, error in
          if let error = error {
                  print("Error: \(error.localizedDescription)")
                  completion(false)
                  return
              }
          if let httpResponse = response as? HTTPURLResponse {
                  print("HTTP Response Status code: \(httpResponse.statusCode)")
              }
     
          // Handle the response from your server
          guard let data = data,
                let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let success = jsonResponse["success"] as? Bool else {
              print("Error: No data received from server")
              completion(false)
              return
          }

          do {
                  if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                      if let success = jsonResponse["success"] as? Bool, success == true,
                         let paymentIntentId = jsonResponse["paymentIntentId"] as? String {
                              PaymentConfig.shared.paymentIntendId = paymentIntentId
                                             completion(success)
                      } else if let error = jsonResponse["error"] as? String {
                          print("Error from server: \(error)")
                          completion(false)
                      }
                  } else {
                      print("Error: Unable to parse JSON response")
                      completion(false)
                  }
              } catch {
                  print("Error: \(error.localizedDescription)")
                  completion(false)
              }
      }.resume()
    }


    private func createAndConfirmPaymentMethod(paymentMethodParams: STPPaymentMethodParams, completion: @escaping (Bool) -> Void) {
        // Create a Stripe PaymentMethod with the given parameters
        STPAPIClient.shared.createPaymentMethod(with: paymentMethodParams) { paymentMethod, error in
            guard let paymentMethodId = paymentMethod?.stripeId, error == nil else {
                print("Error: \(error?.localizedDescription)")
                completion(false)
                return
            }

            // Assuming you have a server function to handle the server-side logic
            self.createAndConfirmPaymentIntent(paymentMethodId: paymentMethodId, completion: completion)
        }
    }
}

