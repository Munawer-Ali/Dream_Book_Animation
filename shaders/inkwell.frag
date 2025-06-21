void main() {
    vec2 xy = FlutterFragCoord().xy;
    vec2 center = resolution * 0.5;

    float dx = origin - pointer;
    float x = container.z - dx;

    float d = xy.x - x;

    // When the fragment is outside of the radius
    if (d > r) {
        fragColor = TRANSPARENT;

        // Adjust the alpha value based on distance outside the radius
        if (inRect(xy, container)) {
            fragColor.a = mix(0.5, 0.0, (d - r) / r);
        }
    }
    // When the fragment is within the transition zone of the radius
    else if (d > 0.0) {
        float theta = asin(d / r);
        float d1 = theta * r;
        float d2 = (PI - theta) * r;
        const float HALF_PI = PI / 2.0;

        vec2 s = vec2(1.0 + (1.0 - sin(HALF_PI + theta)) * 0.1);
        mat3 transform = scale(s, center);
        vec2 uv = project(xy, transform);
        vec2 p1 = vec2(x + d1, uv.y);

        s = vec2(1.1 + sin(HALF_PI + theta) * 0.1);
        transform = scale(s, center);
        uv = project(xy, transform);
        vec2 p2 = vec2(x + d2, uv.y);

        if (inRect(p2, container)) {
            fragColor = texture(image, p2 / resolution);
        } else if (inRect(p1, container)) {
            fragColor = texture(image, p1 / resolution);
            fragColor.rgb *= pow(clamp((r - d) / r, 0.0, 1.0), 0.2);
        } else if (inRect(xy, container)) {
            // FIXED: Show original image instead of black shadow
            fragColor = texture(image, xy / resolution);
            
            // Alternative options:
            // fragColor = TRANSPARENT;  // For complete transparency
            // fragColor = vec4(1.0, 1.0, 1.0, 0.05);  // For white subtle overlay
        }
    }
    // When the fragment is inside the radius
    else {
        vec2 s = vec2(1.2);
        mat3 transform = scale(s, center);
        vec2 uv = project(xy, transform);

        vec2 p = vec2(x + abs(d) + PI * r, uv.y);
        if (inRect(p, container)) {
            fragColor = texture(image, p / resolution);
        } else {
            fragColor = texture(image, xy / resolution);
        }
    }
}
