varying vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

uniform vec2 center;

void main()
{
    vec2 normCoord = 2.0 * textureCoordinate - 1.0;
    vec2 normCenter = 2.0 * center - 1.0;
    
    normCoord -= normCenter;
    vec2 s = sign(normCoord);
    normCoord = abs(normCoord);
    normCoord = 0.5 * normCoord + 0.5 * smoothstep(0.25, 0.5, normCoord) * normCoord;
    normCoord = s * normCoord;
    
    normCoord += normCenter;
    
    vec2 textureCoordinateToUse = normCoord / 2.0 + 0.5;
    
    gl_FragColor = texture2D(inputImageTexture, textureCoordinateToUse);
}