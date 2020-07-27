 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform lowp float sensitivity;
 
 void main()
 {
     mediump vec3 derivativeElements = texture2D(inputImageTexture, textureCoordinate).rgb;
     
     mediump float derivativeSum = derivativeElements.x + derivativeElements.y;
     
     // R = (Ix^2 * Iy^2 - Ixy * Ixy) / (Ix^2 + Iy^2)
     mediump float zElement = (derivativeElements.z * 2.0) - 1.0;
     //     mediump float harrisIntensity = (derivativeElements.x * derivativeElements.y - (derivativeElements.z * derivativeElements.z)) / (derivativeSum);
     mediump float cornerness = (derivativeElements.x * derivativeElements.y - (zElement * zElement)) / (derivativeSum);
     
     // Original Harris detector
     // R = Ix^2 * Iy^2 - Ixy * Ixy - k * (Ix^2 + Iy^2)^2
     //     highp float harrisIntensity = derivativeElements.x * derivativeElements.y - (derivativeElements.z * derivativeElements.z) - harrisConstant * derivativeSum * derivativeSum;
     
     //     gl_FragColor = vec4(vec3(harrisIntensity * 7.0), 1.0);
     gl_FragColor = vec4(vec3(cornerness * sensitivity), 1.0);
 }
