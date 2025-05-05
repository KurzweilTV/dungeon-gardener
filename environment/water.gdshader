shader_type canvas_item;

uniform int iteration_times : hint_range(1, 20) = 5;
uniform float speed : hint_range(0.0, 10.0) = 1.0;
uniform vec4 color = vec4(0.0, 0.35, 0.5, 1.0);
uniform float intensity : hint_range(0.0001, 0.1) = 0.005;

void fragment() {
	vec2 p = mod(UV * TAU, TAU) - 250.0;
	vec2 i = p;
	float c = 1.0;
	float t = TIME * speed;

	for (int n = 0; n < iteration_times; n++) {
		i = p + vec2(
			cos(t - i.x) + sin(t + i.y),
			sin(t - i.y) + cos(t + i.x)
		);

		c += 1.0 / length(vec2(
			p.x / (sin(i.x + t) / intensity),
			p.y / (cos(i.y + t) / intensity)
		));
	}

	c /= float(iteration_times);
	c = 1.17 - pow(c, 1.4);
	vec4 col = vec4(pow(abs(c), 8.0));
	col = clamp(col + color, 0.0, 1.0);

	COLOR = col;
}