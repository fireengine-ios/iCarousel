//
//  HSVMultiband.swift
//  Depo
//
//  Created by Konstantin Studilin on 07.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import CoreImage
import UIKit

extension UIColor {
    func hue() -> CGFloat {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getHue(&hue,
                    saturation: &saturation,
                    brightness: &brightness,
                    alpha: &alpha)
        
        return hue
    }
}


enum HSVMultibandColor: CaseIterable {
    case red
    case orange
    case yellow
    case green
    case aqua
    case blue
    case purple
    case magenta
    
    var color: UIColor {
        switch self {
            case .red:
                return UIColor(red: 0.901961, green: 0.270588, blue: 0.270588, alpha: 1)
            case .orange:
                return UIColor(red: 0.901961, green: 0.584314, blue: 0.270588, alpha: 1)
            case .yellow:
                return UIColor(red: 0.901961, green: 0.901961, blue: 0.270588, alpha: 1)
            case .green:
                return UIColor(red: 0.270588, green: 0.901961, blue: 0.270588, alpha: 1)
            case .aqua:
                return UIColor(red: 0.270588, green: 0.901961, blue: 0.901961, alpha: 1)
            case .blue:
                return UIColor(red: 0.270588, green: 0.270588, blue: 0.901961, alpha: 1)
            case .purple:
                return UIColor(red: 0.584314, green: 0.270588, blue: 0.901961, alpha: 1)
            case .magenta:
                return UIColor(red: 0.901961, green: 0.270588, blue: 0.901961, alpha: 1)
        }
    }
    
    var hue: CGFloat {
        return color.hue()
    }
}



final class HSVMultiband: CIFilter, BasicFilter {
    private let HSVMultibandKernel: CIColorKernel = {
        let red = HSVMultibandColor.red.hue
        let orange = HSVMultibandColor.orange.hue
        let yellow = HSVMultibandColor.yellow.hue
        let green = HSVMultibandColor.green.hue
        let aqua = HSVMultibandColor.aqua.hue
        let blue = HSVMultibandColor.blue.hue
        let purple = HSVMultibandColor.purple.hue
        let magenta = HSVMultibandColor.magenta.hue
        
        var shaderString = ""
        
        shaderString += "#define red \(red) \n"
        shaderString += "#define orange \(orange) \n"
        shaderString += "#define yellow \(yellow) \n"
        shaderString += "#define green \(green) \n"
        shaderString += "#define aqua \(aqua) \n"
        shaderString += "#define blue \(blue) \n"
        shaderString += "#define purple \(purple) \n"
        shaderString += "#define magenta \(magenta) \n"
        
        shaderString += "vec3 rgb2hsv(vec3 c)"
        shaderString += "{"
        shaderString += "    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);"
        shaderString += "    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));"
        shaderString += "    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));"
        
        shaderString += "    float d = q.x - min(q.w, q.y);"
        shaderString += "    float e = 1.0e-10;"
        shaderString += "    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);"
        shaderString += "}"
        
        shaderString += "vec3 hsv2rgb(vec3 c)"
        shaderString += "{"
        shaderString += "    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);"
        shaderString += "    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);"
        shaderString += "    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);"
        shaderString += "}"
        
        shaderString += "vec3 smoothTreatment(vec3 hsv, float hueEdge0, float hueEdge1, vec3 shiftEdge0, vec3 shiftEdge1)"
        shaderString += "{"
        shaderString += " float smoothedHue = smoothstep(hueEdge0, hueEdge1, hsv.x);"
        shaderString += " float hue = hsv.x + (shiftEdge0.x + ((shiftEdge1.x - shiftEdge0.x) * smoothedHue));"
        shaderString += " float sat = hsv.y * (shiftEdge0.y + ((shiftEdge1.y - shiftEdge0.y) * smoothedHue));"
        shaderString += " float lum = hsv.z * (shiftEdge0.z + ((shiftEdge1.z - shiftEdge0.z) * smoothedHue));"
        shaderString += " return vec3(hue, sat, lum);"
        shaderString += "}"
        
        shaderString += "kernel vec4 kernelFunc(__sample pixel,"
        shaderString += "  vec3 redShift, vec3 orangeShift, vec3 yellowShift, vec3 greenShift,"
        shaderString += "  vec3 aquaShift, vec3 blueShift, vec3 purpleShift, vec3 magentaShift)"
        
        shaderString += "{"
        shaderString += " vec3 hsv = rgb2hsv(pixel.rgb); \n"
        
        shaderString += " if (hsv.x < orange){                          hsv = smoothTreatment(hsv, 0.0, orange, redShift, orangeShift);} \n"
        shaderString += " else if (hsv.x >= orange && hsv.x < yellow){  hsv = smoothTreatment(hsv, orange, yellow, orangeShift, yellowShift); } \n"
        shaderString += " else if (hsv.x >= yellow && hsv.x < green){   hsv = smoothTreatment(hsv, yellow, green, yellowShift, greenShift);  } \n"
        shaderString += " else if (hsv.x >= green && hsv.x < aqua){     hsv = smoothTreatment(hsv, green, aqua, greenShift, aquaShift);} \n"
        shaderString += " else if (hsv.x >= aqua && hsv.x < blue){      hsv = smoothTreatment(hsv, aqua, blue, aquaShift, blueShift);} \n"
        shaderString += " else if (hsv.x >= blue && hsv.x < purple){    hsv = smoothTreatment(hsv, blue, purple, blueShift, purpleShift);} \n"
        shaderString += " else if (hsv.x >= purple && hsv.x < magenta){ hsv = smoothTreatment(hsv, purple, magenta, purpleShift, magentaShift);} \n"
        shaderString += " else {                                        hsv = smoothTreatment(hsv, magenta, 1.0, magentaShift, redShift); }; \n"
        
        shaderString += "return vec4(hsv2rgb(hsv), 1.0);"
        shaderString += "}"
        
        return CIColorKernel(source: shaderString)!
    }()
    
    var inputImage: CIImage?
    
    private var filteredColor: HSVMultibandColor = .red
    
    private var inputRedShift = CIVector(x: 0, y: 1, z: 1)
    private var inputOrangeShift = CIVector(x: 0, y: 1, z: 1)
    private var inputYellowShift = CIVector(x: 0, y: 1, z: 1)
    private var inputGreenShift = CIVector(x: 0, y: 1, z: 1)
    private var inputAquaShift = CIVector(x: 0, y: 1, z: 1)
    private var inputBlueShift = CIVector(x: 0, y: 1, z: 1)
    private var inputPurpleShift = CIVector(x: 0, y: 1, z: 1)
    private var inputMagentaShift = CIVector(x: 0, y: 1, z: 1)
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "HSVMultiband",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputRedShift": [kCIAttributeIdentity: 0,
                              kCIAttributeClass: "CIVector",
                              kCIAttributeDisplayName: "Red Shift (HSL)",
                              kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                              kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                              kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputOrangeShift": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "CIVector",
                                 kCIAttributeDisplayName: "Orange Shift (HSL)",
                                 kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                                 kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                                 kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputYellowShift": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "CIVector",
                                 kCIAttributeDisplayName: "Yellow Shift (HSL)",
                                 kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                                 kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                                 kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputGreenShift": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "CIVector",
                                kCIAttributeDisplayName: "Green Shift (HSL)",
                                kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                                kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                                kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputAquaShift": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "CIVector",
                               kCIAttributeDisplayName: "Aqua Shift (HSL)",
                               kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                               kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                               kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputBlueShift": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "CIVector",
                               kCIAttributeDisplayName: "Blue Shift (HSL)",
                               kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                               kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                               kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputPurpleShift": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "CIVector",
                                 kCIAttributeDisplayName: "Purple Shift (HSL)",
                                 kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                                 kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                                 kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputMagentaShift": [kCIAttributeIdentity: 0,
                                  kCIAttributeClass: "CIVector",
                                  kCIAttributeDisplayName: "Magenta Shift (HSL)",
                                  kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                                  kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                                  kCIAttributeType: kCIAttributeTypePosition3],
        ]
    }
    
    override var outputImage: CIImage?{
        guard let inputImage = inputImage else {
            return nil
        }
        
        return HSVMultibandKernel.apply(extent: inputImage.extent,
                                        arguments: [inputImage,
                                                    inputRedShift,
                                                    inputOrangeShift,
                                                    inputYellowShift,
                                                    inputGreenShift,
                                                    inputAquaShift,
                                                    inputBlueShift,
                                                    inputPurpleShift,
                                                    inputMagentaShift])
    }
    
    
    func set(color: HSVMultibandColor) {
        guard color != filteredColor else {
            return
        }
        
        resetColors()
    }
    
    private func resetColors() {
        inputRedShift = CIVector(x: 0, y: 1, z: 1)
        inputOrangeShift = CIVector(x: 0, y: 1, z: 1)
        inputYellowShift = CIVector(x: 0, y: 1, z: 1)
        inputGreenShift = CIVector(x: 0, y: 1, z: 1)
        inputAquaShift = CIVector(x: 0, y: 1, z: 1)
        inputBlueShift = CIVector(x: 0, y: 1, z: 1)
        inputPurpleShift = CIVector(x: 0, y: 1, z: 1)
        inputMagentaShift = CIVector(x: 0, y: 1, z: 1)
    }
    
    func set(hue: Float) {
        let newHue = CGFloat(hue)
        
        switch filteredColor {
            case .red:
                inputRedShift = CIVector(x: newHue, y: inputRedShift.y, z: inputRedShift.z)
            case .orange:
                inputOrangeShift = CIVector(x: newHue, y: inputOrangeShift.y, z: inputOrangeShift.z)
            case .yellow:
                inputYellowShift = CIVector(x: newHue, y: inputYellowShift.y, z: inputYellowShift.z)
            case .green:
                inputGreenShift = CIVector(x: newHue, y: inputGreenShift.y, z: inputGreenShift.z)
            case .aqua:
                inputAquaShift = CIVector(x: newHue, y: inputAquaShift.y, z: inputAquaShift.z)
            case .blue:
                inputBlueShift = CIVector(x: newHue, y: inputBlueShift.y, z: inputBlueShift.z)
            case .purple:
                inputPurpleShift = CIVector(x: newHue, y: inputPurpleShift.y, z: inputPurpleShift.z)
            case .magenta:
                inputMagentaShift = CIVector(x: newHue, y: inputMagentaShift.y, z: inputMagentaShift.z)
        }
    }
    
    func set(saturation: Float) {
        let newSaturation = CGFloat(saturation)
        
        switch filteredColor {
            case .red:
                inputRedShift = CIVector(x: inputRedShift.x, y: newSaturation, z: inputRedShift.z)
            case .orange:
                inputOrangeShift = CIVector(x: inputOrangeShift.x, y: newSaturation, z: inputOrangeShift.z)
            case .yellow:
                inputYellowShift = CIVector(x: inputYellowShift.x, y: newSaturation, z: inputYellowShift.z)
            case .green:
                inputGreenShift = CIVector(x: inputGreenShift.x, y: newSaturation, z: inputGreenShift.z)
            case .aqua:
                inputAquaShift = CIVector(x: inputAquaShift.x, y: newSaturation, z: inputAquaShift.z)
            case .blue:
                inputBlueShift = CIVector(x: inputBlueShift.x, y: newSaturation, z: inputBlueShift.z)
            case .purple:
                inputPurpleShift = CIVector(x: inputPurpleShift.x, y: newSaturation, z: inputPurpleShift.z)
            case .magenta:
                inputMagentaShift = CIVector(x: inputMagentaShift.x, y: newSaturation, z: inputMagentaShift.z)
        }
    }
    
    func set(luminosity: Float) {
        let newLuminosity = CGFloat(luminosity)
        
        switch filteredColor {
            case .red:
                inputRedShift = CIVector(x: inputRedShift.x, y: inputRedShift.y, z: newLuminosity)
            case .orange:
                inputOrangeShift = CIVector(x: inputOrangeShift.x, y: inputOrangeShift.y, z: newLuminosity)
            case .yellow:
                inputYellowShift = CIVector(x: inputYellowShift.x, y: inputYellowShift.y, z: newLuminosity)
            case .green:
                inputGreenShift = CIVector(x: inputGreenShift.x, y: inputGreenShift.y, z: newLuminosity)
            case .aqua:
                inputAquaShift = CIVector(x: inputAquaShift.x, y: inputAquaShift.y, z: newLuminosity)
            case .blue:
                inputBlueShift = CIVector(x: inputBlueShift.x, y: inputBlueShift.y, z: newLuminosity)
            case .purple:
                inputPurpleShift = CIVector(x: inputPurpleShift.x, y: inputPurpleShift.y, z: newLuminosity)
            case .magenta:
                inputMagentaShift = CIVector(x: inputMagentaShift.x, y: inputMagentaShift.y, z: newLuminosity)
        }
    }
}
