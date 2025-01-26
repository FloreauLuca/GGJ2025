//--------------
// Create with the help of : 
// - https://www.youtube.com/watch?v=S8AWd66hoCo
// - https://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/
// - https://www.youtube.com/watch?v=Cp5WWtMoeKg&ab_channel=SebastianLague
// - https://michaelwalczyk.com/blog-ray-marching.html
//--------------
Shader"MorphShader"
{
    Properties
    {
        //_MyColor("Some Color", Color) = (1,1,1,1)
        //_MyVector("Some Vector", Vector) = (0,0,0,0)
        //_MyRange("My Range", Range(0, 1)) = 1
        //_MyFloat("My float", Float) = 0.5
        //_MyInt("My Int", int) = 1
        //_MyTexture2D("Texture2D", 2D) = "white" {}
        //_MyTexture3D("Texture3D", 3D) = "white" {}
        //_MyCubemap("Cubemap", CUBE) = "" {}
        _MainTex("Texture", 2D) = "white" {}
        _SpherePos("SpherePos", Vector) = (0,0,0)
        //_SphereRadius("SphereRadius", Float) = 1

        _Smooth("Smooth", Float) = 1

        _Color("Color", Color) = (1,1,1,1)
        _FresnelStrength("FresnelStrength", Float) = 1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull front 
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define SURF_DIST 1e-3

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ro : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            int _SphereCount = 1;
            float3 _SpherePos;
            float4 _SpheresPos[10];
            float _SpheresRadius[10];
            float _SphereRadius;

            float _Smooth;

            float4 _Color;
            float _FresnelStrength;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.ro = _WorldSpaceCameraPos;
                o.hitPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float sdSphere(float3 p, float3 c, float s)
            {
                return length(p - c) - s;
            }
            float sdBox(float3 p, float3 c, float3 b)
            {
                float3 q = abs(p - c) - b;
                return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
            }
            float sdEllipsoid(float3 p, float3 c, float3 r)
            {
                float k0 = length(p - c / r);
                float k1 = length(p - c / (r * r));
                return k0 * (k0 - 1.0) / k1;
            }
            float3 noiseSphere(float3 p, float3 c, float s)
            {
                float displacement = sin(5.0 * p.x) * sin(5.0 * p.y) * sin(5.0 * p.z) * 0.25;
                float sphere_0 = sdSphere(p, c, s);

                return sphere_0 + displacement;
            }

            float intersectSDF(float distA, float distB)
            {
                return max(distA, distB);
            }

            float unionSDF(float distA, float distB)
            {
                return min(distA, distB);
            }

            float differenceSDF(float distA, float distB)
            {
                return max(distA, -distB);
            }

            float smoothMin(float distA, float distB, float k)
            {
                float h = max(k-abs(distA-distB), 0) / k;
                return min(distA, distB) - h*h*h*k*1/6.0;
            }

            float sceneSDF(float3 p)
            {
                float scene = 1;
                for(int i = 0; i < _SphereCount; i++)
                {
                    float sphere = sdSphere(p, _SpheresPos[i], _SpheresRadius[i]); // sphere
                    scene = smoothMin(sphere, scene, _Smooth);
                }
                //float square = sdBox(p, float3(0,-1,0), float3(0.7,0.1,0.6));
                return scene;
            }
            
            float GetDist(float3 p)
            {
                return sceneSDF(p);
            }

            float Raymarch(float3 ro, float3 rd)
            {
                float dO = 0;
                float dS;
                for (int i = 0; i < MAX_STEPS; i++)
                {
                    float3 p = ro + dO * rd;
                    dS = GetDist(p);
                    dO += dS;
                    if (dS < SURF_DIST || dO > MAX_DIST)
                    break;
                }
                return dO;
            }

            float3 GetNormal(float3 p)
            {
                float2 e = float2(1e-2, 0);
                float3 n = GetDist(p) - float3(
                GetDist(p - e.xyy),
                GetDist(p - e.yxy),
                GetDist(p - e.yyx)
                );
                return normalize(n);
            }
            
            float4 computeTexture(float3 n, float3 ro)
            {
                float fresnel = clamp(1.0-dot(normalize(n),normalize(ro)) * _FresnelStrength, 0.0,1.0);
                float4 color = _Color * fresnel;
                return color;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv - .5;
                float3 ro = i.ro;
                float3 rd = normalize(i.hitPos - ro);
                
                float d = Raymarch(ro, rd);
                fixed4 col = 0;

                if (d > MAX_DIST)
                {
                    discard;
                }

                float3 p = ro + rd * d;
                float3 n = GetNormal(p);
                col.rgba = computeTexture(n, ro);
                //col.rgba = float4(float3(d/MAX_DIST, d/MAX_DIST, d/MAX_DIST), 1); depthh
                return col;
            }
            ENDCG
        }
    }
}
