//
//  ViewController.swift
//  AMDrawingView Demo
//
//  Created by Steve Landey on 7/23/18.
//  Copyright © 2018 Asana. All rights reserved.
//

import UIKit
import Drawsana

/**
 Bare-bones demonstration of the Drawsana API. Drawsana does not provide its
 own UI, so this demo has a very simple one.
 */
class ViewController: UIViewController {
  lazy var drawingView: DrawsanaView = {
    let drawingView = DrawsanaView()
    drawingView.delegate = self
    drawingView.operationStack.delegate = self
    return drawingView
  }()

  let toolButton = UIButton(type: .custom)
  let undoButton = UIButton()
  let redoButton = UIButton()

  /// Instance of `TextTool` for which we are the delegate, so we can respond
  /// to relevant UI events
  lazy var textTool = { return TextTool(delegate: self) }()

  /// Instance of `SelectionTool` for which we are the delegate, so we can
  /// respond to relevant UI events
  lazy var selectionTool = { return SelectionTool(delegate: self) }()

  lazy var tools: [DrawingTool] = { return [
    textTool,
    selectionTool,
    EllipseTool(),
    PenTool(),
    EraserTool(),
    LineTool(),
    RectTool(),
  ] }()
  var toolIndex = 0

  // Just AutoLayout code here
  override func loadView() {
    self.view = UIView()

    toolButton.translatesAutoresizingMaskIntoConstraints = false
    toolButton.setTitle("No Tool", for: .normal)
    toolButton.addTarget(self, action: #selector(changeTool(_:)), for: .touchUpInside)
    toolButton.setContentHuggingPriority(.required, for: .vertical)
    view.addSubview(toolButton)

    undoButton.translatesAutoresizingMaskIntoConstraints = false
    undoButton.setTitle("<", for: .normal)
    undoButton.addTarget(drawingView.operationStack, action: #selector(DrawingOperationStack.undo), for: .touchUpInside)
    view.addSubview(undoButton)

    redoButton.translatesAutoresizingMaskIntoConstraints = false
    redoButton.setTitle(">", for: .normal)
    redoButton.addTarget(drawingView.operationStack, action: #selector(DrawingOperationStack.redo), for: .touchUpInside)
    view.addSubview(redoButton)

    drawingView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(drawingView)
    NSLayoutConstraint.activate([
      // drawingView constrain to left/top/right
      drawingView.leftAnchor.constraint(equalTo: view.leftAnchor),
      drawingView.rightAnchor.constraint(equalTo: view.rightAnchor),
      drawingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

      // toolButton constrain to center/bottom
      toolButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      toolButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

      // drawingView bottom -> toolButton.top
      drawingView.bottomAnchor.constraint(equalTo: toolButton.topAnchor),

      // undoButton constrain to bottom left
      undoButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 4),
      undoButton.centerYAnchor.constraint(equalTo: toolButton.centerYAnchor),

      // redoButton constrain next to undoButton
      redoButton.leftAnchor.constraint(equalTo: undoButton.rightAnchor, constant: 4),
      redoButton.centerYAnchor.constraint(equalTo: toolButton.centerYAnchor),
    ])
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set initial tool to whatever `toolIndex` says
    drawingView.set(tool: tools[toolIndex])
    applyViewState()
  }

  /// Cycle to the next tool in the list; wrap around to zeroth tool if at end
  @objc private func changeTool(_ sender: Any?) {
    toolIndex = (toolIndex + 1) % tools.count
    drawingView.set(tool: tools[toolIndex])
    applyViewState()
  }

  /// Update button states to reflect undo stack and user settings
  private func applyViewState() {
    undoButton.isEnabled = drawingView.operationStack.canUndo
    redoButton.isEnabled = drawingView.operationStack.canRedo
    toolButton.setTitle(tools[toolIndex].name, for: .normal)

    for button in [undoButton, redoButton] {
      button.alpha = button.isEnabled ? 1 : 0.5
    }
  }
}

extension ViewController: DrawsanaViewDelegate {
  /// When tool changes, update the UI
  func drawsanaView(_ drawsanaView: DrawsanaView, didSwitchTo tool: DrawingTool?) {
    toolButton.setTitle(tool?.name, for: .normal)
  }
}

extension ViewController: SelectionToolDelegate {
  /// When a shape is double-tapped by the selection tool, and it's text,
  /// begin editing the text
  func selectionToolDidTapOnAlreadySelectedShape(_ shape: ShapeSelectable) {
    if shape as? TextShape != nil {
      drawingView.set(tool: textTool, shape: shape)
    }
  }
}

extension ViewController: TextToolDelegate {
  /// Don't modify text point. In reality you probably do want to modify it to
  /// make sure it's not below the keyboard.
  func textToolPointForNewText(tappedPoint: CGPoint) -> CGPoint {
    return tappedPoint
  }

  /// When user taps away from text, switch to the selection tool so they can
  /// tap anything they want.
  func textToolDidTapAway(tappedPoint: CGPoint) {
    toolIndex = tools.index(where: { ($0 as? SelectionTool) === self.selectionTool })!
    drawingView.set(tool: tools[toolIndex])
  }
}

/// Implement `DrawingOperationStackDelegate` to keep the UI in sync with the
/// operation stack
extension ViewController: DrawingOperationStackDelegate {
  func drawingOperationStackDidUndo(_ operationStack: DrawingOperationStack, operation: DrawingOperation) {
    applyViewState()
  }

  func drawingOperationStackDidRedo(_ operationStack: DrawingOperationStack, operation: DrawingOperation) {
    applyViewState()
  }

  func drawingOperationStackDidApply(_ operationStack: DrawingOperationStack, operation: DrawingOperation) {
    applyViewState()
  }
}
