 //
//  KVAnimationSegmentView.swift
//  WBActionSegmentView
//
//  Created by kevin on 04/10/2019.
//  Copyright © 2019 kevin. All rights reserved.
//

import UIKit

/// 세그 먼트 액션
public class KVAnimationSegmentAction {
    /// 타이틀 액션
    public var title: String

    /// 타이틀 액션
    public var compeletion: (() -> Void)?

    /// 컬러
    public var titleColor: UIColor?

    /// 타이틀 액션
    public init(title: String, titleColor: UIColor? = nil, compeletion: (() -> Void)?) {
        self.title = title
        self.compeletion = compeletion
        self.titleColor = titleColor
    }
}

/// 액션이 있는 세그먼트 뷰
open class KVAnimationSegmentView: UIView {

    /// 라인을 좀더 넓게 표시할때
    open var lineInset = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
        }
    }

    /// lienHeight
    open var lineHeight: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }

    static let DefaultAnimationDuration = CATransaction.animationDuration()

    /// 언더라인 뷰
    private lazy var underLine: UIView = {
        return UIView()
    }()

    /// 컨텐트영역 여백
    open var contentInset: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8) {
        didSet {
            setNeedsLayout()
        }
    }

    /// 폰트가 변경
    open var font: UIFont = UIFont.systemFont(ofSize: UIFont.buttonFontSize) {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }

    /// 현재 인덱스
    private var currentIndex: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 버튼 사이의 스페이싱, 기본값은 8
    open var spacing: CGFloat = 8 {
        didSet {
            setNeedsLayout()
        }
    }

    /// 언더라인 보여줄지 여부
    private var showLine: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 언더라인 뷰
    private lazy var lineView: UIView = {
        return UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 1))
    }()

    /// 액션들
    private var actions: [KVAnimationSegmentAction] = []

    /// 버튼들
    private var buttons: [UIButton] = []

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }

    /// 준비하는 함수
    private func prepare() {
        // 테스트 코드
        // self.backgroundColor = .lightGray
    }

    /// 버튼이 눌렸을 때 호출
    @objc private func buttonTapped(_ sender: UIButton) {
        let tag = sender.tag
        currentIndex = tag

        moveView(lineView, toButtonIndex: currentIndex)

        // 액션 실행
        let action = actions[tag]
        action.compeletion?()
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        debugPrint("draw")

        if showLine {
            if lineView.superview == nil {
                addSubview(lineView)
            }
        } else {
            if lineView.superview != nil {
                lineView.removeFromSuperview()
            }
        }

        for button in buttons {
            // 버튼은 선택된 상태로 한다
            button.isSelected = (button.tag == currentIndex)
            button.titleLabel?.font = font
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        debugPrint("layoutSubviews")

        let contentRect = self.bounds.inset(by: contentInset)

        let buttonWidth = (contentRect.width - (spacing * CGFloat(buttons.count - 1))) / CGFloat(buttons.count)
        let buttonHeight = contentRect.height

        var x = contentRect.minX

        for button in buttons {
            button.frame = CGRect.init(x: x, y: 0, width: buttonWidth, height: buttonHeight)
            x = button.frame.maxX + spacing
        }

        if showLine {
            lineView.frame = lineViewFrame(at: currentIndex)
            lineView.backgroundColor = lineViewColor(at: currentIndex)
        }

    }

    /// 텍스트 폭 구하기
    private func titleSize(text: String, font: UIFont) -> CGSize {
        let string: NSString = text as NSString
        let size = string.size(withAttributes: [NSAttributedString.Key.font: font])

        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }

    /// 라인 프레임
    private func lineViewFrame(at index: Int) -> CGRect {
        let action = actions[index]
        let button = buttons[index]
        let titleSize = self.titleSize(text: action.title, font: font)

        var width: CGFloat = titleSize.width

        if let titleLabelWidth = button.titleLabel?.frame.width, titleLabelWidth > 0 {
            width = fmin(titleLabelWidth, titleSize.width)
        }
        
        return CGRect(x: button.frame.midX - (width / 2) + lineInset.left,
                      y: bounds.height - 1,
                      width: width - lineInset.left - lineInset.right,
                      height: lineHeight)
    }

    /// 라인 컬러
    private func lineViewColor(at index: Int) -> UIColor? {
        let button = buttons[index]
        return button.tintColor
    }

    /// 무빙 에니메이션
    private func moveView(_ view: UIView, toButtonIndex index: Int) {
        UIView.animate(withDuration: KVAnimationSegmentView.DefaultAnimationDuration) { [weak self] in
            guard let `self` = self else { return }
            self.lineView.frame = self.lineViewFrame(at: index)
        }
    }
}

// MARK:- Public Method
extension KVAnimationSegmentView {
    /// 액션을 추가하는 함수
    open func addAction(_ action: KVAnimationSegmentAction) {
        // 액션 추가
        actions.append(action)

        // 버튼도 추가
        let button = UIButton.init(type: .custom)
        button.setTitle(action.title, for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.setTitleColor(button.tintColor, for: .selected)

        if let color = action.titleColor {
            button.tintColor = color
        }
        button.tag = (actions.count - 1)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        addSubview(button)
        buttons.append(button)

        // 재정렬 필요
        setNeedsLayout()
    }
}

