shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    // Calculate the grayscale value
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    // Set the final color to grayscale
    color.rgb = vec3(gray);
    COLOR = color;
}
