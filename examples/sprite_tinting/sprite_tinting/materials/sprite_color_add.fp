varying mediump vec2 var_texcoord0;

uniform lowp sampler2D DIFFUSE_TEXTURE;
uniform lowp vec4 tint;
uniform lowp vec4 color_add;

void main()
{
	vec4 texColor = texture2D(DIFFUSE_TEXTURE, var_texcoord0.xy);
	vec4 color = vec4(texColor.rgb + (color_add.rgb * color_add.w), texColor.w);
	texColor.rgba = color * texColor.w;
	lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
	gl_FragColor = texColor * tint_pm;
}
