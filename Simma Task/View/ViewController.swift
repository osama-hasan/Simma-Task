//
//  ViewController.swift
//  Simma Task
//
//  Created by Osama Hasan on 15/10/2023.
//

import UIKit
import SwiftSoup
import WebKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var checkoutButton: UIButton!
    var currentButtonState: ButtonState = .checkout
    var cartProducts : [CartProduct] = []
    
    lazy var backButton: UIBarButtonItem = {
        let backButtonImage = UIImage(systemName: "arrow.backward")
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        return backButton
    }()
    
    lazy var forwardButton: UIBarButtonItem = {
        let forwardButtonImage = UIImage(systemName: "arrow.forward")
        let forwardButton = UIBarButtonItem(image: forwardButtonImage, style: .plain, target: self, action: #selector(forwardButtonTapped))
        return forwardButton
    }()
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        
        webConfiguration.userContentController.add(self, name: "buttonClicked") // Register the message handler
        // Do any additional setup after loading the view.
        
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        let url = URL(string: "https://us.shein.com")!
        //
        //
        let reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadButtonTapped))
        
        
        navigationItem.rightBarButtonItems = [forwardButton,backButton]
        navigationItem.leftBarButtonItem = reloadButton
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        
        checkoutButton.layer.cornerRadius = 12
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        
        
        let safeArea = view.safeAreaLayoutGuide

        let leadingConstraint = NSLayoutConstraint(item: webView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: webView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: webView!, attribute: .top, relatedBy: .equal, toItem: safeArea, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: webView!, attribute: .bottom, relatedBy: .equal, toItem: checkoutButton, attribute: .top, multiplier: 1, constant: 0)
        
        // Activate the constraints
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
        
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey] as? URL {
            print("observeValue \(key)") // url value
            if key.absoluteString.contains("cart"){
              //  injectJavaScript()
                setButtonText(by: .cart)
                return
            }
            setButtonText(by: .checkout)
        }
    }
    func setButtonText(by state:ButtonState){
        currentButtonState = state
        switch state{
            
        case .checkout:
            checkoutButton.setTitle("Checkout", for: .normal)
        case .cart:
            checkoutButton.setTitle("Show Cart", for: .normal)
        }
    }
    func updateButtonState() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
    
    func extractHtml( completion: @escaping (_ success:Bool)->Void){
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: { (html, error) in
            if let htmlString = html as? String {
                do {
                    
                    
                    let document = try SwiftSoup.parse(htmlString)
                    
                    let cartItems = try document.select(".cart-item-content")
                    if !cartItems.isEmpty() {
                        self.cartProducts = []
                    }
                    try cartItems.forEach { item in
                        if let titleElement = try item.select(".right-struct span").first(),let priceElement = try item.select(".cart-item-price .price-amount-decimal").first(),let imgElement = try item.select(".left-img img").first(),let quantityElement = try document.select(".cart-item__stepper-num").first() {
                            
                            let price = try priceElement.children().array().map({ try $0.text()}).joined()
                            
                            let title = try titleElement.text()
                            let imgURL = try imgElement.attr("src")
                            let value = try quantityElement.val()
                            
                            let product = CartProduct(imageUrl: "https:\(imgURL)", quantity: value, price: price, title: title)
                            self.cartProducts.append(product)
                            //print("Title: \(title)")
                        }
                        
                        if let quantityElement = try document.select(".cart-item__stepper-num").first() {
                            
                            try quantityElement.attr("type", "text")
                            print(try quantityElement.val())
                        }
                    }
                    
                    print(self.cartProducts)
                    completion(true)
                    
                } catch {
                    print("Error parsing HTML: \(error)")
                }
            }
        })
    }
    
    @objc func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc func forwardButtonTapped() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    @objc func reloadButtonTapped() {
        webView.reload()
    }
    
    
    @IBAction func checkoutTap(_ sender: Any) {
        if currentButtonState == .checkout {
            let url = URL(string: "https://m.shein.com/us/cart")!
            webView.load(URLRequest(url: url))
            return
        }
        extractHtml { success in
            let cartVC = CartViewController()
            cartVC.cartItems = self.cartProducts
            self.navigationController?.pushViewController(cartVC, animated: true)
        }

    }
    
}


extension ViewController : WKNavigationDelegate,WKScriptMessageHandler {
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString.contains("cart") ?? false{
            injectJavaScript()
        }
        updateButtonState()
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateButtonState()
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        updateButtonState()
        decisionHandler(.allow)
        
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Handle messages sent from JavaScript
        if message.name == "buttonClicked" {
            // Handle the button click event
            extractHtml{ success in
                let cartVC = CartViewController()
                cartVC.cartItems = self.cartProducts
                self.navigationController?.pushViewController(cartVC, animated: true)
            }

        }
    }
    
    func injectJavaScript() {
        let script = """
                var button = document.querySelector(".S-button.newcomer-guide__checkout");
                button.addEventListener("click", function() {
                    window.webkit.messageHandlers.buttonClicked.postMessage("");
                });
                """
        webView.evaluateJavaScript(script, completionHandler: { (result, error) in
            if let error = error {
                print("Error executing JavaScript: \(error)")
            } else {
                // JavaScript code executed successfully
                print("JavaScript executed successfully")
            }
        })
    }
    
}


struct CartProduct {
    var imageUrl : String
    var quantity : String
    var price : String
    var title : String
}


enum ButtonState{
    case checkout
    case cart
}
