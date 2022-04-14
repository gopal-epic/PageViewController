//
//  CreateAccountPopupViewController.swift
//  Epic
//
//  Created by Gopal Rao Gurram on 3/22/22.
//  Copyright © 2022 Epic. All rights reserved.
//

import UIKit

class CreateAccountPopupViewController: ScrollFormViewController {

    @IBOutlet var contentView: UIView?
    @IBOutlet weak var backButton: UIButton?
    @IBOutlet weak var closeButton: UIButton?
    @IBOutlet weak var stackView: UIStackView?
    @IBOutlet weak var pageControl: UIPageControl?
    @IBOutlet weak var createAccountButton: UIButton?
    @IBOutlet weak var alreadyHaveAnAccountButton: UIButton?
    @IBOutlet weak var useSVGAssetsButton: UIButton?

    private var pageViewController: UIPageViewController?
    private var pages: [CreateAccountPopupModel] = CreateAccountPopupModel.getPages()
    private var currentPage: CreateAccountPopupModel?
    private var currentIndex: Int = 0
    private var timerModel: EpicTimerModel?
    private var isAnimatingRotateCarousel = false
    struct EpicTimerModelConstants {
        static let kTimeFrequencyForRotatingCarousel = 5.0
    }
    private let source = "value_prop_popup"
    static let keyCreateAccountPopupShownDate = "keyCreateAccountPopupShownDate"
    var usePDFImage = false

    @IBAction func closeOrBackButtonAction(_ sender: UIButton) {
        
    }

    @IBAction func createAccountButtonAction(_ sender: UIButton) {
        usePDFImage = true
        alreadyHaveAnAccountButton?.setTitleColor(UIColor.blue, for: .normal)
        createAccountButton?.setTitleColor(UIColor.gray, for: .normal)
    }

    @IBAction func alreadyHaveAnAccountButtonAction(_ sender: UIButton) {
        usePDFImage = false
        createAccountButton?.setTitleColor(UIColor.blue, for: .normal)
        alreadyHaveAnAccountButton?.setTitleColor(UIColor.gray, for: .normal)
    }
    
    @IBAction func useSVGAssetsButtonAction(_ sender: UIButton) {
        usePDFImage = false
        createAccountButton?.setTitleColor(UIColor.blue, for: .normal)
        alreadyHaveAnAccountButton?.setTitleColor(UIColor.gray, for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        //adjust vertical spacing to accomodate different screen heights
        self.view.layoutIfNeeded()

        currentPage = pages[currentIndex]

        setupPageViewController()

        if pages.count > 1 {
            self.timerModel = EpicTimerModel(with: EpicTimerModelConstants.kTimeFrequencyForRotatingCarousel, delayStartingTimer: true, target: self, andJob: #selector(rotateCarousel))
        }

        pageControl?.numberOfPages = pages.count
        pageControl?.hidesForSinglePage = true
        
        pageControl?.currentPage = currentPage?.index ?? currentIndex
        createAccountButton?.setTitle("Use PDF Images", for: .normal)
        alreadyHaveAnAccountButton?.setTitle("Use PNG Images", for: .normal)
        useSVGAssetsButton?.setTitle("Use SVG Images", for: .normal)
        
        alreadyHaveAnAccountButton?.setTitleColor(UIColor.gray, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        resumeTimer()

        if let stackView = stackView {
            pageViewController?.view.bringSubviewToFront(stackView)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        timerModel?.stopTimer()
        timerModel = nil
    }

    private func setupPageViewController() {
        guard let currentPage = currentPage,
              let contentView = contentView,
              let stackView = stackView
        else { return }

        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        guard let pageViewController = pageViewController
        else { return }

        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.backgroundColor = .clear
        pageViewController.view.frame = view.frame
        contentView.insertSubview(pageViewController.view, belowSubview: stackView) // for passing user touches to bottom view

        let initialVC = CreateAccountPageViewController(with: currentPage, usePDFImage: usePDFImage)
        pageViewController.setViewControllers([initialVC], direction: .forward, animated: true, completion: nil)
    }

    @objc func resumeTimer() {
        timerModel?.startTimer()
    }

    @objc func rotateCarousel() {
        if let scrollView = scrollView,
           scrollView.contentOffset.x != view.bounds.width,
           isAnimatingRotateCarousel {
            // only move if we are resting, i.e. user not moving the view
            return
        }

        guard let pageViewController = pageViewController,
              let current = pageViewController.viewControllers?.first,
              let newPageViewController = self.pageViewController(pageViewController, viewControllerAfter: current) as? CreateAccountPageViewController
        else { return }

        currentIndex = newPageViewController.page.index
        pageControl?.currentPage = currentIndex
        isAnimatingRotateCarousel = true
        pageViewController.setViewControllers([newPageViewController], direction: .forward, animated: true) { [weak self] _ in
            guard let self = self else { return }

            self.isAnimatingRotateCarousel = false
        }
    }

    func viewControllerAtIndex(_ index: Int) -> CreateAccountPageViewController? {
        currentPage = pages[index]
        guard let currentPage = currentPage else { return nil }
        
        return CreateAccountPageViewController(with: currentPage, usePDFImage: usePDFImage)
    }
}

extension CreateAccountPopupViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        timerModel?.stopTimer()
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let currentPageViewController = pageViewController.viewControllers?.first as? CreateAccountPageViewController {
            currentIndex = currentPageViewController.page.index
            pageControl?.currentPage = currentIndex
        }

        resumeTimer()
    }
}

extension CreateAccountPopupViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let viewController = viewController as? CreateAccountPageViewController
        else { return nil }

        var newIndex = viewController.page.index - 1
        if newIndex < 0 {
            newIndex = pages.count - 1
        }

        return viewControllerAtIndex(newIndex)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let viewController = viewController as? CreateAccountPageViewController
        else { return nil }

        var newIndex = viewController.page.index + 1
        if newIndex >= pages.count {
            newIndex = 0
        }

        return viewControllerAtIndex(newIndex)
    }
}
