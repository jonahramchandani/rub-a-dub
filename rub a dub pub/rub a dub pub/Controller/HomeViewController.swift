//
//  HomeViewController.swift
//  rub a dub
//
//  Created by Jonah Ramchandani on 21/02/2024.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let pubBrain = PubBrain()
    
    var firstTitle = UILabel()
    var secondTitle = UILabel()
    var thirdTitle = UILabel()
    var firstSubtitle = UILabel()
    var secondSubtitle = UILabel()
    var thirdSubtitle = UILabel()
    var titleList: [UILabel] = []
    var subtitleList: [UILabel] = []
    
    let ref: DatabaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        pageControl.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)
        
        // Load data from Realtime DB
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Create the space for the scroll view...
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - 10)
        
        // And populate it manually
        configureScrollView()
    }
    
//MARK: - Function to parse data from Realtime DB and use it to populate the Pub Brain
    
    @MainActor
    func loadData() {
        async {
            do {
                let pubData = try await self.ref.child("17w0ijLwmxQlHAi1VCxs9aAxf7mg7cgKES1H-EbTJkVQ/RDMasterSheet").getData()
                var counter = PubBrain.pubs.count
                for child in pubData.children {
                    if let pubSnapshot = child as? DataSnapshot {
                        if let pubData = pubSnapshot.value as? [String: Any] {
                            let pubFromData = pubBrain.pubConverter(pubData: pubData, id: counter)
                            PubBrain.pubs.append(pubFromData)
                            counter += 1
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
//MARK: - Manually creating the image carousel because IB was taking years off my life
    
    private func configureScrollView() {
        
        // Set content size to 3x the width of the frame
        scrollView.contentSize = CGSize(width: view.frame.size.width * 3, height: scrollView.frame.size.height - 10)
        
        // Enable paging to create carousel effect
        scrollView.isPagingEnabled = true
        
        // List of images for the carousel
        let images: [UIImage] = [#imageLiteral(resourceName: "000466160014"), #imageLiteral(resourceName: "000466160005"), #imageLiteral(resourceName: "000466160021")]
        
        // Programatically creating the labels... sigh //
        // Create and position the text
        firstTitle.frame = CGRect(x: 25, y: scrollView.frame.size.height - 150, width: 400, height: 56)
        firstTitle.text = "Rub a Dub"
        
        // Set font, colour, size
        titleFormat(firstTitle)
        
        // Add to list for a loop later
        titleList.append(firstTitle)
        
        
        // And rinse and repeat for all titles and subtitles...
        // The only extra thing is the gesture recognizer for the pool and quiz titles
    
        secondTitle.frame = CGRect(x: 25 + view.frame.size.width, y: scrollView.frame.size.height - 150, width: 400, height: 56)
        secondTitle.text = "Rack 'Em Up"
        secondTitle.isUserInteractionEnabled = true
        let poolTitleTapped = UITapGestureRecognizer(target: self, action: #selector(poolTapped))
        secondTitle.addGestureRecognizer(poolTitleTapped)
        titleFormat(secondTitle)
        titleList.append(secondTitle)
        
        thirdTitle.frame = CGRect(x: 25 + (2 * view.frame.size.width), y: scrollView.frame.size.height - 150, width: 400, height: 56)
        thirdTitle.text = "Quiz Today"
        thirdTitle.isUserInteractionEnabled = true
        let quizTitleTapped = UITapGestureRecognizer(target: self, action: #selector(quizTapped))
        thirdTitle.addGestureRecognizer(quizTitleTapped)
        titleFormat(thirdTitle)
        titleList.append(thirdTitle)
        
        firstSubtitle.frame = CGRect(x: 25, y: scrollView.frame.size.height - 100, width: 300, height: 70)
        firstSubtitle.numberOfLines = 0
        firstSubtitle.text = "Pubs, pubs, pubs everywhere. Pull up a stool, order a beer."
        subtitileFormat(firstSubtitle)
        subtitleList.append(firstSubtitle)
        
        secondSubtitle.frame = CGRect(x: 25 + view.frame.size.width, y: scrollView.frame.size.height - 100, width: 300, height: 70)
        secondSubtitle.numberOfLines = 0
        secondSubtitle.text = "Find pool tables near you. Click here to get started."
        secondSubtitle.isUserInteractionEnabled = true
        let poolSubtitleTapped = UITapGestureRecognizer(target: self, action: #selector(poolTapped))
        secondSubtitle.addGestureRecognizer(poolSubtitleTapped)
        subtitileFormat(secondSubtitle)
        subtitleList.append(secondSubtitle)
        
        thirdSubtitle.frame = CGRect(x: 25 + (2 * view.frame.size.width), y: scrollView.frame.size.height - 100, width: 300, height: 70)
        thirdSubtitle.numberOfLines = 0
        thirdSubtitle.text = "Find a pub quiz today. Click here to get started."
        thirdSubtitle.isUserInteractionEnabled = true
        let quizSubitleTapped = UITapGestureRecognizer(target: self, action: #selector(quizTapped))
        thirdSubtitle.addGestureRecognizer(quizSubitleTapped)
        subtitileFormat(thirdSubtitle)
        subtitleList.append(thirdSubtitle)
        
        
        // Now for populating the scroll view itself...
        // Loop through the number of pages...
        
        for x in 0..<3 {
            
            // Use the width of the frame and x as a multiple to set the position of the left most point
            let page = UIImageView(frame: CGRect(x: CGFloat(x) * view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height - 10))
            
            // Use image from the earlier array to fill the page
            page.contentMode = .scaleAspectFill
            page.image = images[x]
            page.clipsToBounds = true
            
            scrollView.addSubview(page)
        }
        
        // And now we add the titles so they can sit on top of the image
        
        scrollView.addSubview(firstTitle)
        scrollView.addSubview(secondTitle)
        scrollView.addSubview(thirdTitle)
        scrollView.addSubview(firstSubtitle)
        scrollView.addSubview(secondSubtitle)
        scrollView.addSubview(thirdSubtitle)
        
        // And the page control !
        
        view.bringSubviewToFront(pageControl)
        
        // Add the fade in effect for text
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            UIView.animate(withDuration: 0.7) {
                self.titleList[self.pageControl.currentPage].alpha = 1
                self.subtitleList[self.pageControl.currentPage].alpha = 1
            }
        }
    }
    
    // Add the optionality to click on the page control instead of swiping to move across the carousel
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let current = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(current) * view.frame.size.width, y: 0), animated: true)
        
        // And set the text back to 0 alpha so it fades each time the image changes (with a tiny delay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for x in 0..<3 {
                self.titleList[x].alpha = 0
                self.subtitleList[x].alpha = 0
            }
        }
    }
    
    // Text formatting functions to trim the long section earlier
    
    func titleFormat(_ title: UILabel) {
        title.font = UIFont(name: "Palatino", size: 50)
        title.textColor = #colorLiteral(red: 1, green: 0.9836458564, blue: 0.9667497277, alpha: 1)
        title.alpha = 0
    }
    
    func subtitileFormat(_ title: UILabel) {
        title.font = UIFont(name: "Palatino", size: 20)
        title.textColor = #colorLiteral(red: 1, green: 0.9836458564, blue: 0.9667497277, alpha: 1)
        title.alpha = 0
    }


//MARK: - Shortcuts for pub quiz and pool table segues
    
    @objc func poolTapped() {
        if let tabBar = self.tabBarController {
            FilterBrain.filterDictionary["pool"] = { $0.pool }
            FilterBrain.filterArray.append("pool")
            FilterBrain.brain["pool"] = true
            tabBar.selectedIndex = 2
        }
    }
    
    @objc func quizTapped() {
        if let tabBar = self.tabBarController {
            FilterBrain.filterDictionary["quiz"] = { $0.quiz == FilterBrain.quiz }
            FilterBrain.filterArray.append("quiz")
            FilterBrain.quiz = timeBrain.fetchWeekDay()
            tabBar.selectedIndex = 2
        }
    }
}


//MARK: - Scroll Delegate stuff - trigger fades and changes in text when carousel is swiped

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.pageControl.currentPage != Int(scrollView.contentOffset.x / scrollView.frame.size.width) {
            self.pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        }
        
        for x in 0..<3 {
            if x != self.pageControl.currentPage {
                self.titleList[x].alpha = 0
                self.subtitleList[x].alpha = 0
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.7) {
                self.titleList[self.pageControl.currentPage].alpha = 1
                self.subtitleList[self.pageControl.currentPage].alpha = 1
                
            }
        }
    }
}
