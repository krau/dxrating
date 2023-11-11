import UIKit
import Capacitor
import CoreSpotlight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // common controllers
        let root = window?.rootViewController
        let rootView = root?.view
        
        // MARK: Capacitor enhancements on WebView
        
        // set background to black to retain visual consistancy
        rootView?.backgroundColor = UIColor.black
        
        // enable bounces since Capacitor seems to disabled it
        rootView?.scrollView.bounces = true
        
        // disable pinch gesture
        rootView?.scrollView.pinchGestureRecognizer?.isEnabled = false
        
        if let options = launchOptions {
            let notif = options[UIApplication.LaunchOptionsKey.remoteNotification] as? [NSDictionary]
            print("remote notification launch option", notif ?? "null")
        }

        let topBarColorChunk = UIView()
        topBarColorChunk.backgroundColor = .init(rgb: 0xC8A8F9)
        topBarColorChunk.translatesAutoresizingMaskIntoConstraints = false
        rootView?.addSubview(topBarColorChunk)

        guard let leadingAnchor = rootView?.leadingAnchor,
              let widthAnchor   = rootView?.widthAnchor,
              let topAnchor     = rootView?.topAnchor,
              let bottomAnchor  = rootView?.safeAreaLayoutGuide.topAnchor
        else {
            return true
        }

        topBarColorChunk.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topBarColorChunk.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        topBarColorChunk.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topBarColorChunk.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        // Override point for customization after application launch.
        
        DispatchQueue.global(qos: .background).async {
            if let dxData = AppData.loadDXData() {
                if #available(iOS 14.0, *) {
                    var items: [CSSearchableItem] = []
                    for song in dxData.songs {
                        let id = "\(song.songId)"
                        let attributeSet = CSSearchableItemAttributeSet(contentType: .item)
                        attributeSet.title = song.title
                        attributeSet.displayName = song.title
                        attributeSet.contentDescription = song.sheets
                            .map({ sheet in
                                return sheet.formatted()
                            })
                            .joined(separator: " | ")
                        attributeSet.identifier = song.songId
                        attributeSet.alternateNames = song.searchAcronyms
                        if #available(iOS 15.0, *) {
                            attributeSet.actionIdentifiers = ["STAR_UNSTAR"]
                        }
                        if let thumbnailURL = Bundle.main.url(forResource: song.imageName.replacingOccurrences(of: ".png", with: ""), withExtension: "jpg", subdirectory: "Assets/Covers") {
                            attributeSet.thumbnailURL = thumbnailURL
                        } else {
                            print("unable to find thumbnail for \(song.imageName)")
                        }
                        let item = CSSearchableItem(uniqueIdentifier: "\(song.songId)", domainIdentifier: "dev.imgg.gekichumai.dxrating", attributeSet: attributeSet)
                        item.expirationDate = .distantFuture
                        items.append(item)
                    }
                    CSSearchableIndex.default().indexSearchableItems(items) { error in
                        if let error = error {
                            print("Indexing error: \(error.localizedDescription)")
                        } else {
                            print("Successfully indexed \(items.count) items.")
                        }
                    }
                }
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Called when the app was launched with a url. Feel free to add additional processing here,
        // but if you want the App API to support tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Called when the app was launched with an activity, including Universal Links.
        // Feel free to add additional processing here, but if you want the App API to support
        // tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

}