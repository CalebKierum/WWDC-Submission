//  Settings.swift
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb Kierum. All rights reserved.
//

import Metal
import CoreGraphics

public class Settings {
    public static var sampleCount:Int = 1 //Dont set this to anything other than 1 for compatability reasons
    public static var colorFormat:MTLPixelFormat = .rgba8Unorm
}
public class SlotContants {
    public static var totalScale:CGFloat = 0.13
    public static var majorLow:CGFloat = 0.9
    public static var sizeScalar:CGFloat = 0.8//0.9
    public static var displacementScalar:CGFloat = 1.4
}
