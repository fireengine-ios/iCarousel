varying highp vec2 textureCoordinate;
varying highp vec2 textureCoordinate2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

void main()
{
   lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
   lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
   
   gl_FragColor = max(textureColor, textureColor2);
}