#version 330 core
out vec4 FragColor;

in vec2 texCoord;

uniform sampler2D diffuse;
uniform sampler2D lightmap;
uniform vec3 camPos;

void main()
{
    vec4 diffuseColor  = texture(diffuse,  texCoord);
    vec4 lightmapColor = texture(lightmap, texCoord);
    FragColor = diffuseColor * lightmapColor;
}