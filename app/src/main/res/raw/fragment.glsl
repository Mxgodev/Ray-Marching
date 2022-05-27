precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

const float FOV = 1.0;
const float MAX_STEPS = 256.0;
const float MAX_DIST = 500.0;
const float EPSILON = 0.001;

//Идентификаторы объектов
const float SPHERE_ID = 1.0;
const float PLANE_ID = 2.0;
const float TORUS_ID = 3.0;

vec2 smin( vec2 a, vec2 b, float k )
{
    float h = max( k-abs(a.x-b.x), 0.0 )/k;
    return vec2(min( a.x, b.x ) - h*h*k*(1.0/4.0), a.x < b.x ? a.y : b.y);
}

//Функции расстояния
float dSphere(vec3 p, float r) {
    return length(p) - r;
}

float dPlane(vec3 p, vec3 n, float d) {
    return dot(p, n) + d;
}

float dTorus(vec3 p, vec2 r) {
    float x = length(p.xz)-r.x;
    return length(vec2(x, p.y))-r.y;
}

//Операции
vec2 oUnion(vec2 o1, vec2 o2) {
    return (o1.x < o2.x) ? o1 : o2;
}

//Вращение
void rot(inout vec2 p, float a) {
    p = cos(a) * p + sin(a) * vec2(p.y, -p.x);
}

vec2 map(vec3 p) {

    //Cфера
    float sphereDist = dSphere(p + vec3(0, sin(u_time), 0), 1.0);
    vec2 sphere = vec2(sphereDist, SPHERE_ID);

//    //Тор
//    float torusDist = dTorus(p, vec2(2, 0.5));
//    vec2 torus = vec2(torusDist, TORUS_ID);


    //Плоскость
    float planeDist = dPlane(p, vec3(0.0, 1.0, 0.0), 1.0);
    vec2 plane = vec2(planeDist, PLANE_ID);

    vec2 res;
    res = smin(plane, sphere, 0.5);
//    res = oUnion(res, torus);

    return res;
}

vec2 rayMarch(vec3 ro, vec3 rd) {
    vec2 hit, object;
    for (float i = 0.0; i < MAX_STEPS; i++) {
        vec3 p = ro + object.x * rd;
        hit = map(p);
        object.x += hit.x;
        object.y = hit.y;
        if (abs(hit.x) < EPSILON || object.x > MAX_DIST) break;
    }

    return object;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(EPSILON, 0);
    vec3 n = vec3(map(p).x) - vec3(
    map(p - e.xyy).x,
    map(p - e.yxy).x,
    map(p - e.yyx).x
    );

    return normalize(n);
}

vec3 getLight(vec3 p, vec3 rd, vec3 color) {
    vec3 lightPos = vec3(20.0, 40.0, -30.0);
    vec3 l = normalize(lightPos - p);
    vec3 n = getNormal(p);
    vec3 v = -rd;
    vec3 r = reflect(-l, n);

    vec3 specColor = vec3(0.5);
    vec3 specular = specColor * pow(clamp(dot(r, v), 0.0, 1.0), 10.0);
    vec3 diffuse = color * clamp(dot(l, n), 0.0, 1.0);
    vec3 ambient = color * 0.1;

    //Тени
    float d = rayMarch(p + n * 0.02, normalize(lightPos)).x;
    if(d < length(lightPos - p)) return ambient;
    return specular + diffuse + ambient;
}

vec3 getMaterial(vec3 p, float id) {
    vec3 m;
    if(id == SPHERE_ID) {
        m = vec3(0.9,0.9, 0.0);
    }

    if(id == PLANE_ID) {
        m = vec3(0.2 + 0.4 * mod(floor(p.x) + floor(p.z), 2.0));
    }

    if(id == TORUS_ID) {
        m = vec3(0.9, 0.1, 0.1);
    }

    return m;
}

mat3 getCam(vec3 ro, vec3 lookAt) {
    vec3 f = normalize(lookAt - ro);
    vec3 r = normalize(cross(vec3(0, 1, 0), f));
    vec3 u = cross(f, r);
    return mat3(r, u, f);
}

void render(inout vec3 col, in vec2 uv) {
    vec3 ro = vec3(3, 3, -4); //Положение камеры
    rot(ro.xz, u_time);
    vec3 lookAt = vec3(0, 0, 0);

    vec3 rd = getCam(ro, lookAt) * normalize(vec3(uv, FOV));

    vec2 object = rayMarch(ro, rd);


    vec3 background = vec3(0.5, 0.8, 0.9);

    if (object.x < MAX_DIST) {
        vec3 p = ro + object.x * rd;
        vec3 material = getMaterial(p, object.y);
        col += getLight(p, rd, material);

        //Туман
        col = mix(col, background, 1.0 - exp(-0.001 * object.x * object.x));
    } else {
        col += background - max(0.95 * rd.y, 0.0);
    }
}

void main()
{
    //Текущий пиксель
    vec2 uv = (gl_FragCoord.xy - .5 * u_resolution.xy) / min(u_resolution.x, u_resolution.y);

    vec3 col;

    render(col, uv);

    col = pow(col, vec3(0.4545));
    gl_FragColor = vec4(col, 1.0);
}