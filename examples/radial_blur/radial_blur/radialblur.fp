// https://www.shadertoy.com/view/4ts3Ws

uniform sampler2D T;

varying vec2 var_texcoord0;

const float amount = 80.0;
uniform lowp vec4 start_position;

void main()
{
	vec2 position = -1.0 + 2.0 * var_texcoord0.xy;
	vec2 current_step = position;
	
	vec2 direction = (start_position.xy - position) / amount;
	
	vec3 total = vec3(0.0);
	for(int i = 0; i < int(amount); i++)
	{
		vec2 uv;
		uv.x = sin(0.0 + 1.0) + current_step.x;
		uv.y = sin(0.0 + 1.0) + current_step.y;
		vec3 result = texture2D(T, uv * 0.5).xyz;
		
		result = smoothstep(0.0, 1.0, result);
		total += result;
		current_step += direction;
	}
	total /= amount;
	gl_FragColor = vec4(total, 1.0);
}
