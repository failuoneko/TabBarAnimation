//
//  ViewController.swift
//
//  Created by L on 2022/12/16.
//  Copyright © 2022 All rights reserved.
//

import UIKit

class TabBarPageViewController: UIViewController {

    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var tabCollectionView: UICollectionView!
    @IBOutlet weak var tabPageScrollView: UIScrollView!
    @IBOutlet weak var tabCollectionViewHeight: NSLayoutConstraint!
    
    // 調整用參數
    /// tab高度
    var tabHeight: CGFloat = 40
    /// 底線寬度是否等於Label
    var isHighlightWidthEqualToLabel: Bool = true
    /// tabBar寬度是否等於螢幕寬度
    var isTabBarWidthEqualToScreen: Bool = false
    
    var currentPage: Int = 0 {
        didSet {
            guard oldValue != currentPage else { return }
            let indexPath = IndexPath(item: currentPage, section: 0)
            tabCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
    private var constraints: [NSLayoutConstraint] = []
    
    private var pageTitleList: [String] = ["TEST1", "TEST222", "TEST33333", "T4", "T5555", "T6666666666666"]
    private var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = createViewControllers(with: pageTitleList)
        setTabBarPage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setTagTitleAndViewControllers(pageTitleList: pageTitleList, viewControllers: viewControllers)
        setDefaultSelected()
    }
    
    func setTagTitleAndViewControllers(pageTitleList: [String], viewControllers: [UIViewController]) {
        self.pageTitleList = pageTitleList
        self.viewControllers = viewControllers
        
        configureScrollView()
    }
    
    private func setTabBarPage() {
        tabCollectionView.delegate = self
        tabCollectionView.dataSource = self
        tabCollectionViewHeight.constant = tabHeight
        
        tabPageScrollView.delegate = self
    }
    
    func setDefaultSelected() {
        
        guard self.pageTitleList.count > 1 else { return }
        
        DispatchQueue.main.async { [weak self] in
            
            // 設定初始tab
            self?.tabCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .right)
            
            // 初始HighlightLine
            self?.setHighlightLine(item: 0,lineScrollDistance: 0, time: 0)
        }
    }
    
    private func setHighlightLine(item: Int, lineScrollDistance: CGFloat, time: Double) {
        guard let currentTabCell = tabCollectionView.cellForItem(at: IndexPath(item: item, section: 0)) as? TabBarCollectionViewCell else { return }
        
        NSLayoutConstraint.deactivate(constraints)
        highlightView.translatesAutoresizingMaskIntoConstraints = false

        var highlightWidth: NSLayoutDimension
        if isHighlightWidthEqualToLabel {
            highlightWidth = currentTabCell.titleLabel.widthAnchor
        } else {
            highlightWidth = currentTabCell.widthAnchor
        }
        
        constraints = [
            highlightView.centerXAnchor.constraint(equalTo: currentTabCell.titleLabel.centerXAnchor, constant: lineScrollDistance * -1.0),
            highlightView.widthAnchor.constraint(equalTo: highlightWidth)
        ]

        NSLayoutConstraint.activate(constraints)
        
        UIView.animate(withDuration: time) {
            self.view.layoutIfNeeded()
        }
    }
}

extension TabBarPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pageTitleList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
            // 標籤欄
        case self.tabCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabBarCollectionViewCell.reuseIdentifier, for: indexPath) as! TabBarCollectionViewCell
            cell.setTitle(title: pageTitleList[indexPath.item])
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case self.tabCollectionView:
            changeCellAndPage(indexPath: indexPath)
        default:
            ()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // 翻頁後
        if scrollView == tabPageScrollView {
            let index = Int(targetContentOffset.pointee.x / tabPageScrollView.frame.width)
            let indexPath = IndexPath(item: index, section: 0)
            DispatchQueue.main.async { [weak self] in
                self?.tabCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        switch scrollView {
        case self.tabCollectionView:
            ()
            
        case self.tabPageScrollView:
            
            let nowOffsetX = scrollView.contentOffset.x
            let pageWidth = scrollView.bounds.width
            self.currentPage = Int(floor((nowOffsetX - pageWidth / 2) / pageWidth)) + 1
            
            guard let currentTabCell = tabCollectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as? TabBarCollectionViewCell else { return }
            
            guard let vcView = viewControllers[currentPage].view else { return }
            
            let sectionWidth = currentTabCell.frame.width
            let sectionFraction = sectionWidth / UIScreen.main.bounds.width
            
            // 底線滑動距離 = page滑動距離 * (tabItem寬度 / tab總寬度)
            let point = vcView.convert(CGPoint.zero, to: self.view)
            let lineScrollDistance = point.x * sectionFraction
            
            setHighlightLine(item: currentPage, lineScrollDistance: lineScrollDistance, time: 0.2)
            
        default:
            ()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        switch collectionView {
        case self.tabCollectionView:
            return true
        default:
            return false
        }
    }
}

extension TabBarPageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView {
        case self.tabCollectionView:
            
            if isTabBarWidthEqualToScreen == true {
                return CGSize(width: view.frame.width / CGFloat(pageTitleList.count), height: tabHeight)
            } else {
                let textFont = UIFont.init(name: "PingFangTC-Medium", size: 15)!
                let textString = pageTitleList[indexPath.row]
                let textMaxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 32)
                let textLabelSize = textSize(text: textString ,font: textFont , maxSize: textMaxSize)
                return CGSize(width: textLabelSize.width + 50, height: tabHeight)
            }
            
        default:
            return collectionView.bounds.size
        }
    }
}

extension TabBarPageViewController {
    
    private func changeCellAndPage(indexPath: IndexPath) {
        guard self.viewControllers.count == self.pageTitleList.count else { return }
        self.tabCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        tabPageScrollView.setContentOffset(CGPoint.init(x: UIScreen.main.bounds.width * CGFloat(indexPath.item), y: 0), animated: true)
    }
    
    private func textSize(text: String, font: UIFont, maxSize: CGSize) -> CGSize {
        
        return text.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : font], context: nil).size
    }
}

extension TabBarPageViewController {
    
    private func configureScrollView() {
        let contentsView = createContentsView()
        tabPageScrollView.addSubview(contentsView)
        tabPageScrollView.contentSize = contentsView.frame.size
    }
    
    private func createContentsView() -> UIView {
        let contentsView = UIView()
        let contentsWidth = tabPageScrollView.frame.width * CGFloat(viewControllers.count)
        let contentsHeight = tabPageScrollView.frame.height
        contentsView.frame = CGRect(x: 0, y: 0, width: contentsWidth, height: contentsHeight)

        for (index, vc) in viewControllers.enumerated() {
            let pageView = createPages(vc: vc, pageIndex: index)
            contentsView.addSubview(pageView)
        }

        return contentsView
    }
    
    private func createPages(vc: UIViewController, pageIndex: Int) -> UIView {
        
        let pageView = UIView()
        let pageSize = tabPageScrollView.frame.size
        let positionX = pageSize.width * CGFloat(pageIndex)
        let position = CGPoint(x: positionX, y: 0)
        pageView.frame = CGRect(origin: position, size: pageSize)

        addChild(vc)
        pageView.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: pageView.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: pageView.bottomAnchor),
            vc.view.leadingAnchor.constraint(equalTo: pageView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: pageView.trailingAnchor)
        ])
        vc.didMove(toParent: self)
        
        return pageView
    }
    
    private func createViewControllers(with titles: [String]) -> [UIViewController] {
        return titles.map { title -> UIViewController in
            let viewController = UIViewController()
            let label = UILabel()
            
            label.text = title
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            viewController.view.addSubview(label)
            viewController.view.backgroundColor = randomColor()
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
            ])
            
            return viewController
        }
    }
    
    private func randomColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(256)) / 255.0
        let green = CGFloat(arc4random_uniform(256)) / 255.0
        let blue = CGFloat(arc4random_uniform(256)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
