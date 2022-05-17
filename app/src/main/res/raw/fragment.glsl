precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.1415925359
#define TWO_PI 6.2831852
#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURFACE_DIST .01

mat2 Rot(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

float Torus(vec3 p, vec2 r) {
    float x = length(p.xz)-r.x;
    return length(vec2(x, p.y)) - r.y;
}

float Sphere(vec3 p, float r) {
    return length(p) - r;
}

float GetDist(vec3 p) {

    vec3 tp = p - vec3(0, 3, 6);
    tp.xz *= Rot(u_time);
    float td = Torus(tp, vec2(1.5, .5));
//    float sd = Sphere(p - vec3(0, 1, 6), 1.);
    //Расстояние до земли
    float pd = p.y;

    float d = min(td, pd);
    return d;
}

float RayMarch(vec3 ro, vec3 rd) {
    float dO = 0.;

    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        float ds = GetDist(p);
        dO += ds;
        if (dO > MAX_DIST || ds < SURFACE_DIST) break;
    }

    return dO;
}

vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(.01, 0);

    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx)
    );

    return normalize(n);
}

float GetLight(vec3 p) {
    vec3 lightPos = vec3(0, 6, 6); //Положение источника света

    vec3 l = normalize(lightPos - p); //Направление света

    vec3 n = GetNormal(p);

    float dif = dot(l, n);


    //Тень
    float d = RayMarch(p + n * 0.05, l);

    if(d < length(lightPos-p)) dif *= .3;

    return clamp(dif, 0., 1.);
}



void main()
{
    //Текущий пиксель
    vec2 uv = (gl_FragCoord.xy - .5 * u_resolution.xy) / u_resolution.y;

    vec3 ro = vec3(0, 5, 0); //Положение камеры

    vec3 rd = normalize(vec3(uv.x, uv.y-.5, 1)); //Направление луча

    float d = RayMarch(ro, rd); //Расстояние до объекта

    vec3 p = ro + rd * d;

    float dif = GetLight(p);

    vec3 color = vec3(dif);

    gl_FragColor = vec4(color, 1.0);
}