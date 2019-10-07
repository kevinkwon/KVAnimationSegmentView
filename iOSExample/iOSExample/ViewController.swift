//
//  ViewController.swift
//  iOSExample
//
//  Created by kevin on 07/10/2019.
//  Copyright © 2019 kevin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var segmentView: KVAnimationSegmentView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        test()
    }

    private func test() {
        segmentView.contentInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        segmentView.lineInset = UIEdgeInsets.init(top: 0, left: -4, bottom: 0, right: -4)
        segmentView.font = UIFont.systemFont(ofSize: 13)
        segmentView.spacing = 8

        let action = KVAnimationSegmentAction.init(title: "Menu1") {
            print("Menu1 버튼 눌림")
        }
        let action2 = KVAnimationSegmentAction.init(title: "Menu2") {
            print("Menu2 버튼 눌림")
        }
        let action3 = KVAnimationSegmentAction.init(title: "Menu3") {
            print("Menu3 버튼 눌림")
        }
        segmentView.addAction(action)
        segmentView.addAction(action2)
        segmentView.addAction(action3)

    }
}

