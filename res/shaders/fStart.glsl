varying vec4 position;
varying vec3 normal;
varying vec2 texCoord;

varying vec4 color;

uniform vec3 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform mat4 ModelView;
uniform mat4 Projection;
uniform vec4 LightPosition;
uniform vec3 LightColor;
uniform float LightBrightness;
uniform float Shininess;

uniform sampler2D texture;

uniform float texScale;


void main()
{
    // Transform vertex position into eye coordinates
    vec3 pos = (ModelView * position).xyz;


    // The vector to the light from the vertex    
    vec3 Lvec = LightPosition.xyz - pos;

    // Unit direction vectors for Blinn-Phong shading calculation
    vec3 L = normalize( Lvec );   // Direction to the light source
    vec3 E = normalize( -pos );   // Direction to the eye/camera
    vec3 H = normalize( L + E );  // Halfway vector

    // Transform vertex normal into eye coordinates (assumes scaling
    // is uniform across dimensions)
    vec3 N = normalize((ModelView*vec4(normal, 0.0)).xyz);

    // Compute terms in the illumination equation
    vec3 ambient = (LightColor * LightBrightness) * AmbientProduct;

    float Kd = max( dot(L, N), 0.0 );
    vec3  diffuse = Kd * (LightColor * LightBrightness) * DiffuseProduct;

    float Ks = pow( max(dot(N, H), 0.0), Shininess );
    vec3  specular = Ks * LightBrightness * SpecularProduct;
    
    if (dot(L, N) < 0.0 ) {
	specular = vec3(0.0, 0.0, 0.0);
    } 

    // globalAmbient is independent of distance from the light source
    vec3 globalAmbient = vec3(0.1, 0.1, 0.1);

    // part F - Adjust light based on distance to object
    float lightDropoff = 0.01 + length(Lvec);

    color.rgb = globalAmbient  + ((ambient + diffuse)/lightDropoff) + specular;
    color.a = 1.0;

    // part B - declare texScale var and replace 2.0
    gl_FragColor = color * texture2D( texture, texCoord * texScale ) + vec4((specular/lightDropoff), 1.0);
}
