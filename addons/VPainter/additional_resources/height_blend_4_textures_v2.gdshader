shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform bool show_colors = false;

//uv scale
uniform bool UV_SCALE = false;
uniform float uv_scale_black:hint_range(0.01, 100.0) = 1;
uniform float uv_scale_red:hint_range(0.01, 100.0) = 1;
uniform float uv_scale_green:hint_range(0.01, 100.0) = 1;
uniform float uv_scale_blue:hint_range(0.01, 100.0) = 1;

//ao scale
uniform bool ao_scale = false;
uniform float ao_scale_black: hint_range(0.,2.) = 1;
uniform float ao_scale_red: hint_range(0.,2.) = 1;
uniform float ao_scale_green: hint_range(0.,2.) = 1;
uniform float ao_scale_blue: hint_range(0.,2.) = 1;

//normal scale
uniform bool normal_scale = false;
uniform float normal_scale_black: hint_range(0.,10.) = 1;
uniform float normal_scale_red: hint_range(0.,10.) = 1;
uniform float normal_scale_green: hint_range(0.,10.) = 1;
uniform float normal_scale_blue: hint_range(0.,10.) = 1;


//textures
uniform bool textures = false;
uniform sampler2D tex_black_albedo: source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D tex_black_normal : hint_normal;
uniform sampler2D tex_black_ao: source_color,filter_linear_mipmap,repeat_enable;

//blend & smooth
uniform bool blend_and_smooth = false;
uniform float blend_smoothness_red : hint_range(0.1, 1.0, 0.01) = 0.2;
uniform float threshold_red : hint_range(0.1, 1.0, 0.01) = 0.0;
uniform float blend_smoothness_green : hint_range(0.1, 1.0, 0.01) = 0.2;
uniform float threshold_green : hint_range(0.1, 1.0, 0.01) = 0.0;
uniform float blend_smoothness_blue : hint_range(0.1, 1.0, 0.01) = 0.2;
uniform float threshold_blue : hint_range(0.1, 1.0, 0.01) = 0.0;


// TEXTURES
uniform sampler2D tex_red_albedo: source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D tex_red_normal : hint_normal;
uniform sampler2D tex_red_ao: source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D tex_green_albedo: source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D tex_green_normal : hint_normal;
uniform sampler2D tex_green_ao: source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D tex_blue_albedo: source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D tex_blue_normal : hint_normal;
uniform sampler2D tex_blue_ao: source_color,filter_linear_mipmap,repeat_enable;



void fragment(){
	// sample all the textures
	vec4 albedo1 = texture(tex_black_albedo, UV*uv_scale_black); //black
	vec4 albedo2 = texture(tex_red_albedo, UV*uv_scale_red); //red
	vec4 albedo3 = texture(tex_green_albedo, UV*uv_scale_green); //green
	vec4 albedo4 = texture(tex_blue_albedo, UV*uv_scale_blue); //blue
	vec3 normal1 = texture(tex_black_normal, UV*uv_scale_black).rgb;
	vec3 normal2 = texture(tex_red_normal, UV*uv_scale_red).rgb;
	vec3 normal3 = texture(tex_green_normal, UV*uv_scale_green).rgb;
	vec3 normal4 = texture(tex_blue_normal, UV*uv_scale_blue).rgb;
	float aoBlack = texture(tex_black_ao, UV*uv_scale_black).r;
	float aoRed = texture(tex_red_ao, UV*uv_scale_red).r;
	float aoGreen = texture(tex_green_ao, UV*uv_scale_green).r;
	float aoBlue = texture(tex_blue_ao, UV*uv_scale_blue).r;
	float mix_factor_red = 0.0;
	float mix_factor_green = 0.0;
	float mix_factor_blue = 0.0;

	mix_factor_red += COLOR.r;
	mix_factor_green += COLOR.g;
	mix_factor_blue += COLOR.b;

	float aoToRemoveBlack = aoBlack * ao_scale_black * (1.-COLOR.r*ao_scale_red-COLOR.g*ao_scale_green-COLOR.b*ao_scale_blue);
	mix_factor_red -= aoGreen*COLOR.g + aoBlue*COLOR.b + aoToRemoveBlack;
	mix_factor_green -= aoRed*COLOR.r * mix_factor_red + aoBlue*COLOR.b + aoToRemoveBlack;
	mix_factor_blue -= aoGreen*COLOR.g * mix_factor_green + aoRed*COLOR.r*mix_factor_red + aoToRemoveBlack;

	mix_factor_red = smoothstep(0.0, blend_smoothness_red, mix_factor_red-threshold_red);
	mix_factor_green = smoothstep(0.0, blend_smoothness_green, mix_factor_green-threshold_green);
	mix_factor_blue = smoothstep(0.0, blend_smoothness_blue, mix_factor_blue-threshold_blue);

	vec3 normal = mix(normal1, normal2, mix_factor_red*normal_scale_red);
	normal = mix(normal, normal3, mix_factor_green*normal_scale_green);
	normal = mix(normal, normal4, mix_factor_blue*normal_scale_blue);
	NORMAL = normal;

	vec3 albedo = clamp(mix(albedo1, albedo2, mix_factor_red).rgb, vec3(0.0), vec3(1.0));
	albedo = clamp(mix(albedo, albedo3.rgb, mix_factor_green).rgb, vec3(0.0), vec3(1.0));
	albedo = clamp(mix(albedo, albedo4.rgb, mix_factor_blue).rgb, vec3(0.0), vec3(1.0));
	ALBEDO = albedo;

	if(show_colors){
		ALBEDO=COLOR.rgb;
	}
}