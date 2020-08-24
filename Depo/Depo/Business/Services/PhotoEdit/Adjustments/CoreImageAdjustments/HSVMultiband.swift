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
    
    func sliderGradientColors(for type: AdjustmentParameterType) -> (startColor: UIColor, endColor: UIColor)? {
        switch type {
        case .hue:
            switch self {
                case .red:
                    return (startColor: UIColor(red: 255 / 255, green: 14 / 255, blue: 154 / 255, alpha: 1),
                            endColor: UIColor(red: 255 / 255, green: 56 / 255, blue: 1 / 255, alpha: 1))
                case .orange:
                    return (startColor: UIColor(red: 145 / 255, green: 13 / 255, blue: 13 / 255, alpha: 1),
                            endColor: UIColor(red: 138 / 255, green: 127 / 255, blue: 13 / 255, alpha: 1))
                case .yellow:
                    return (startColor: UIColor(red: 140 / 255, green: 77 / 255, blue: 13 / 255, alpha: 1),
                            endColor: UIColor(red: 67 / 255, green: 141 / 255, blue: 14 / 255, alpha: 1))
                case .green:
                    return (startColor: UIColor(red: 141 / 255, green: 133 / 255, blue: 11 / 255, alpha: 1),
                            endColor: UIColor(red: 10 / 255, green: 141 / 255, blue: 98 / 255, alpha: 1))
                case .aqua:
                    return (startColor: UIColor(red: 65 / 255, green: 140 / 255, blue: 14 / 255, alpha: 1),
                            endColor: UIColor(red: 13 / 255, green: 35 / 255, blue: 140 / 255, alpha: 1))
                case .blue:
                    return (startColor: UIColor(red: 13 / 255, green: 141 / 255, blue: 99 / 255, alpha: 1),
                            endColor: UIColor(red: 87 / 255, green: 13 / 255, blue: 142 / 255, alpha: 1))
                case .purple:
                    return (startColor: UIColor(red: 14 / 255, green: 34 / 255, blue: 141 / 255, alpha: 1),
                             endColor: UIColor(red: 139 / 255, green: 13 / 255, blue: 78 / 255, alpha: 1))
                case .magenta:
                    return (startColor: UIColor(red: 88 / 255, green: 13 / 255, blue: 141 / 255, alpha: 1),
                            endColor: UIColor(red: 141 / 255, green: 13 / 255, blue: 14 / 255, alpha: 1))
            }
        case .saturation:
            switch self {
                case .red:
                    return (startColor: UIColor(red: 182 / 255, green: 145 / 255, blue: 152 / 255, alpha: 1),
                           endColor: UIColor(red: 255 / 255, green: 4 / 255, blue: 105 / 255, alpha: 1))
                case .orange:
                    return (startColor: UIColor(red: 129 / 255, green: 129 / 255, blue: 129 / 255, alpha: 1),
                            endColor: UIColor(red: 144 / 255, green: 78 / 255, blue: 14 / 255, alpha: 1))
                case .yellow:
                    return (startColor: UIColor(red: 128 / 255, green: 128 / 255, blue: 128 / 255, alpha: 1),
                            endColor: UIColor(red: 142 / 255, green: 132 / 255, blue: 14 / 255, alpha: 1))
                case .green:
                    return (startColor: UIColor(red: 118 / 255, green: 119 / 255, blue: 118 / 255, alpha: 1),
                            endColor: UIColor(red: 68 / 255, green: 143 / 255, blue: 14 / 255, alpha: 1))
                case .aqua:
                    return (startColor: UIColor(red: 128 / 255, green: 128 / 255, blue: 128 / 255, alpha: 1),
                            endColor: UIColor(red: 12 / 255, green: 147 / 255, blue: 103 / 255, alpha: 1))
                case .blue:
                    return (startColor: UIColor(red: 128 / 255, green: 128 / 255, blue: 130 / 255, alpha: 1),
                            endColor: UIColor(red: 13 / 255, green: 35 / 255, blue: 142 / 255, alpha: 1))
                case .purple:
                    return (startColor: UIColor(red: 127 / 255, green: 127 / 255, blue: 127 / 255, alpha: 1),
                             endColor: UIColor(red: 88 / 255, green: 13 / 255, blue: 142 / 255, alpha: 1))
                case .magenta:
                    return (startColor: UIColor(red: 130 / 255, green: 120 / 255, blue: 125 / 255, alpha: 1),
                            endColor: UIColor(red: 141 / 255, green: 14 / 255, blue: 77 / 255, alpha: 1))
            }
        case .intensity:
            switch self {
                case .red:
                    return(startColor: UIColor(red: 88 / 255, green: 0 / 255, blue: 29 / 255, alpha: 1),
                           endColor: UIColor(red: 218 / 255, green: 140 / 255, blue: 155 / 255, alpha: 1))
                case .orange:
                    return (startColor: UIColor(red: 42 / 255, green: 32 / 255, blue: 23 / 255, alpha: 1),
                            endColor: UIColor(red: 134 / 255, green: 113 / 255, blue: 93 / 255, alpha: 1))
                case .yellow:
                    return (startColor: UIColor(red: 41 / 255, green: 39 / 255, blue: 24 / 255, alpha: 1),
                            endColor: UIColor(red: 128 / 255, green: 127 / 255, blue: 123 / 255, alpha: 1))
                case .green:
                    return (startColor: UIColor(red: 29 / 255, green: 36 / 255, blue: 25 / 255, alpha: 1),
                            endColor: UIColor(red: 117 / 255, green: 119 / 255, blue: 117 / 255, alpha: 1))
                case .aqua:
                    return (startColor: UIColor(red: 102 / 255, green: 134 / 255, blue: 123 / 255, alpha: 1),
                            endColor: UIColor(red: 117 / 255, green: 119 / 255, blue: 117 / 255, alpha: 1))
                case .blue:
                    return (startColor: UIColor(red: 22 / 255, green: 27 / 255, blue: 50 / 255, alpha: 1),
                            endColor: UIColor(red: 86 / 255, green: 95 / 255, blue: 138 / 255, alpha: 1))
                case .purple:
                    return (startColor: UIColor(red: 39 / 255, green: 22 / 255, blue: 50 / 255, alpha: 1),
                             endColor: UIColor(red: 120 / 255, green: 103 / 255, blue: 132 / 255, alpha: 1))
                case .magenta:
                    return (startColor: UIColor(red: 48 / 255, green: 22 / 255, blue: 36 / 255, alpha: 1),
                            endColor: UIColor(red: 129 / 255, green: 116 / 255, blue: 123 / 255, alpha: 1))
            }
        default:
            return nil
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
        filteredColor = color
        resetColorShifts()
    }
    
    private func resetColorShifts() {
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
