//
//  ViewController.swift
//  WKWebView-iOS11-Storyboard
//
//  Created by kawaharadai on 2018/05/01.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwordButton: UIBarButtonItem!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        load(urlString: "https://qiita.com/d-kawahara")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeWebViewObsever(webView: self.webView)
    }
    
    // MARK: - Setup Methods
    private func setup() {
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.addWebViewObsever(webView: self.webView)
    }
    
    private func addWebViewObsever(webView: WKWebView) {
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "canGoForward", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
    }
    
    // MARK: - Private Methods
    private func load(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("URLが不正")
            return
        }
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
    
    //observerハンドリング（状態変化するたびにハンドリング）
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        switch keyPath {
            
        case "estimatedProgress":
            // プログレスの値が更新されるごとにプログレスバーを進める
            self.progressBar.setProgress(Float(self.webView.estimatedProgress), animated: true)
            
        case "title":
            // 表示ページのタイトルが変更されるたびにナビバーのタイトルを変更する
            self.title = self.webView.title
            
        case "loading":
            // ローディング状態が変更されたら、インジケーターと更新ボタンの状態を合わせて変更
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.webView.isLoading
            self.refreshButton.isEnabled = !self.webView.isLoading
            
            if self.webView.isLoading {
                self.progressBar.alpha = 1.0
            } else {
                //読み込みが終わったらプログレスバーの値を戻して消す
                self.progressBar.setProgress(0.0, animated: false)
                self.progressBar.alpha = 0.0
            }
            
        case "canGoBack":
            // 戻るアクションの可否が変更されるごとにボタンの活性非活性を入れ替える
            self.backButton.isEnabled = self.webView.canGoBack
            
        case "canGoForward":
            // 進むアクションの可否が変更されるごとにボタンの活性非活性を入れ替える
            self.forwordButton.isEnabled = self.webView.canGoForward
        
        case "URL":
            // 現在いるURLを出力
            print("現在のURL：\(String(describing: self.webView.url?.absoluteString))")
        default: break
            
        }
    }
    
    private func removeWebViewObsever(webView: WKWebView) {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "loading")
        webView.removeObserver(self, forKeyPath: "canGoBack")
        webView.removeObserver(self, forKeyPath: "canGoForward")
        webView.removeObserver(self, forKeyPath: "URL")
    }
    
    // MARK: - Action Methods
    @IBAction func back(_ sender: Any) {
        self.webView.goBack()
    }
    @IBAction func forword(_ sender: Any) {
        self.webView.goForward()
    }
    @IBAction func refresh(_ sender: Any) {
        self.webView.reload()
    }
}

// MARK: - WKNavigationDelegate Methods
extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("読み込み開始")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("読み込み完了")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("読み込み中エラー")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("通信中のエラー")
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // 読み込みを許可
        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate Methods
extension ViewController: WKUIDelegate {
    /// _blank挙動対応
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        guard
            let targetFrame = navigationAction.targetFrame,
            targetFrame.isMainFrame else {
                webView.load(navigationAction.request)
                return nil
        }
        return nil
    }
    
    /// プレビュー表示の許可
    func webView(_ webView: WKWebView,
                 shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        
        return true
    }
    
}
