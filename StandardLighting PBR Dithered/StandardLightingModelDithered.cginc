#ifndef STANDARD_LIGHTING_MODEL_DITHERED
#define STANDARD_LIGHTING_MODEL_DITHERED

#include "Tessellation.cginc"

#define MOD3 float3(443.8975,397.2973, 491.1871)

float ditherNoiseFuncLow(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * MOD3 + _Time.y);
    p3 += dot(p3, p3.yzx + 19.19);
    return frac((p3.x + p3.y) * p3.z);
}

float3 ditherNoiseFuncHigh(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * (MOD3 + _Time.y));
    p3 += dot(p3, p3.yxz + 19.19);
    return frac(float3((p3.x + p3.y)*p3.z, (p3.x + p3.z)*p3.y, (p3.y + p3.z)*p3.x));
}

struct Input
{
    float3 worldNormal;
    INTERNAL_DATA
        float2 uv_texcoord;
};

struct SurfaceOutputDitheredStandard
{
    fixed3 Albedo;
    fixed3 Normal;
    half3 Emission;
    half Metallic;
    half Smoothness;
    half Occlusion;
    fixed Alpha;
    float3 Dithering;
    float Attenuation;
    float SpecularLightmapOcclusion;
};

uniform float4 _Color;
uniform sampler2D _MainTex;
uniform float4 _MainTex_ST;
uniform sampler2D _BumpMap;
uniform float4 _BumpMap_ST;
uniform sampler2D _OcclusionMap;
uniform float4 _OcclusionMap_ST;
uniform float _OcclusionStrength;
uniform sampler2D _EmissionMap;
uniform float4 _EmissionMap_ST;
uniform float4 _EmissionColor;
uniform sampler2D _MetallicGlossMap;
uniform float4 _MetallicGlossMap_ST;

uniform float _Glossiness;
uniform float _Metallic;
uniform float _NoiseScale;
uniform float _SpecularLightmapOcclusion;

uniform float _Tess;
uniform float _minDist;
uniform float _maxDist;

//displace based on height
uniform sampler2D _ParallaxMap;
uniform float4 _ParallaxMap_ST;
uniform float _Parallax;

struct appdata {
    float4 vertex : POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float2 texcoord : TEXCOORD0;
    float2 texcoord1 : TEXCOORD1;
    float2 texcoord2 : TEXCOORD2;
};


inline void LightingDitheredStandard_GI(inout SurfaceOutputDitheredStandard s, UnityGIInput data, inout UnityGI gi)
{
    // Global Illumination and Environment Reflections
    Unity_GlossyEnvironmentData unityGlossyEnvironmentData = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, float3(0, 0, 0));
    gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal, unityGlossyEnvironmentData);

#ifdef LIGHTMAP_ON
    // Quick hack to kill specular in lightmap shadows
    half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, data.lightmapUV.xy);
    half3 bakedColor = DecodeLightmap(bakedColorTex);
    gi.indirect.specular *= lerp(1.0, pow(length(bakedColor), 0.5), s.SpecularLightmapOcclusion);
#endif

    s.Attenuation = data.atten;
}

inline half4 LightingDitheredStandard(inout SurfaceOutputDitheredStandard s, half3 viewDir, UnityGI gi)
{
    SurfaceOutputStandard standardSurfaceOutput = (SurfaceOutputStandard)0;

    // Populate SurfaceOutputStandard struct
    standardSurfaceOutput.Albedo = s.Albedo;
    standardSurfaceOutput.Normal = s.Normal;
    standardSurfaceOutput.Emission = s.Emission;
    standardSurfaceOutput.Metallic = s.Metallic;
    standardSurfaceOutput.Smoothness = s.Smoothness;
    standardSurfaceOutput.Occlusion = s.Occlusion;
    standardSurfaceOutput.Alpha = s.Alpha;

    // Standard Lighting
    float3 standardLightingResult = LightingStandard(standardSurfaceOutput, viewDir, gi).rgb;

    // Final Color
    half4 finalColor = half4(0, 0, 0, 1);
    finalColor.rgb = standardLightingResult;
    finalColor.rgb += standardSurfaceOutput.Emission;
    finalColor.rgb += (s.Dithering * s.Attenuation);

    // Alpha
    finalColor.a = s.Alpha;

    return finalColor;
}

float4 tessDistance(appdata v0, appdata v1, appdata v2) {
    float3 pos0 = mul(unity_ObjectToWorld,v0.vertex).xyz;
    float3 pos1 = mul(unity_ObjectToWorld,v1.vertex).xyz;
    float3 pos2 = mul(unity_ObjectToWorld,v2.vertex).xyz;

    float minDist = _minDist;
    float maxDist = _maxDist;

    float4 tess;
    if (UnityWorldViewFrustumCull(pos0, pos1, pos2, maxDist))
    {
        tess = 0.0f;
    }
    else
    {
        tess = UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
    }

    return tess;
}

void vert(inout appdata v)
{
    #ifdef _PARALLAXMAP
        float d = tex2Dlod(_ParallaxMap, float4(v.texcoord.xy, 0, 0)).r * _Parallax;
        v.vertex.xyz += v.normal * d;
    #endif
}

void surf(Input i, inout SurfaceOutputDitheredStandard o)
{
    // Albedo and Alpha
    float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
    float4 mainTex = tex2D(_MainTex, uv_MainTex);
    o.Albedo = mainTex.rgb * _Color.rgb;
    o.Alpha = mainTex.a * _Color.a;

    // Normal Map
    #ifdef _NORMALMAP
        float2 uv_Normal = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
        o.Normal = UnpackNormal(tex2D(_BumpMap, uv_Normal));
    #endif

    // Emission
    #ifdef _EMISSION
        float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
        o.Emission = (tex2D(_EmissionMap, uv_EmissionMap) * _EmissionColor).rgb;
    #endif

    // Metallic and Smoothness
    #ifdef _METALLICGLOSSMAP
        float2 uv_MetallicGlossMap = i.uv_texcoord * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
        float4 metallicGloss = tex2D(_MetallicGlossMap, uv_MetallicGlossMap);
        o.Metallic = metallicGloss.r * _Metallic;
        o.Smoothness = metallicGloss.a * _Glossiness;
    #else
        o.Metallic =  _Metallic;
        o.Smoothness = _Glossiness;
    #endif

    // Geometric Specular AA (Valve Method)
    float3 vNormalWsDdx = ddx(i.worldNormal.xyz);
    float3 vNormalWsDdy = ddy(i.worldNormal.xyz);
    float flGeometricRoughnessFactor = pow(saturate(max(dot(vNormalWsDdx.xyz, vNormalWsDdx.xyz), dot(vNormalWsDdy.xyz, vNormalWsDdy.xyz))), 0.333);
    o.Smoothness = min(o.Smoothness, 1.0 - flGeometricRoughnessFactor); // Ensure we don't double-count roughness if normal map encodes geometric roughness

    // Ambient Occlusion
    #ifdef _OCCLUSIONMAP
        float2 uv_OcclusionMap = i.uv_texcoord * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
        float4 occlusion = tex2D(_OcclusionMap, uv_OcclusionMap);
        o.Occlusion = lerp(1.0, occlusion, _OcclusionStrength);
    #endif

    // Compute Dithering
    o.Dithering = (ditherNoiseFuncHigh(i.uv_texcoord.xy) - 0.5) * 2 * _NoiseScale;

    // Specular Lightmap Occlusion
    o.SpecularLightmapOcclusion = _SpecularLightmapOcclusion;

    return;
}

#endif
