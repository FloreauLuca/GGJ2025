Shader "MorphShader"
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
      _SphereRadius("SphereRadius", Float) = 1
  }
    SubShader
  {
      Tags { "RenderType" = "Opaque" }
      LOD 100

      Pass
      {
          CGPROGRAM
          #pragma vertex vert
          #pragma fragment frag

          #include "UnityCG.cginc"

#define MAX_STEPS 1000
#define MAX_DIST 1000
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

          float3 _SpherePos;
          float _SphereRadius;

          v2f vert(appdata v)
          {
              v2f o;
              o.vertex = UnityObjectToClipPos(v.vertex);
              o.uv = TRANSFORM_TEX(v.uv, _MainTex);
              o.ro = _WorldSpaceCameraPos; 
              o.hitPos = mul(unity_ObjectToWorld, v.vertex);
              return o;
          }

          float GetDist(float3 p)
          {
            float sphere = length(_SpherePos - p) - _SphereRadius; // sphere
            float torus = length(float2(length(p.xz) - 0.5, p.y)) - .1;
            return min(sphere, torus);
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
              if (dS<SURF_DIST || dO>MAX_DIST) break;
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
              col.rgb = n;
              //col.rgb = ro + 0 * rd;
              return col;
          }
          ENDCG
      }
  }
}
