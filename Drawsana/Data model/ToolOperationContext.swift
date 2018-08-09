//
//  ToolOperationContext.swift
//  Drawsana
//
//  Created by Steve Landey on 8/2/18.
//  Copyright © 2018 Asana. All rights reserved.
//

import CoreGraphics

/**
 Aggregate of objects that may be used by tools during operations
 */
public struct ToolOperationContext {
  let drawing: Drawing
  let operationStack: DrawingOperationStack
  let userSettings: UserSettings
  let toolSettings: ToolSettings
}