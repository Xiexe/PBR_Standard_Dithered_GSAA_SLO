Shader "Xiexe/StandardLightingDithered"
{
    Properties
    {
        // Albedo Map and Tint Color
        _MainTex("MainTex", 2D) = "white" {}
        [HDR]_Color("Color Tint", Color) = (1,1,1,1)

        // Normal Map
        [Normal]_BumpMap("Normal", 2D) = "bump" {}

        // Metallic and Smoothness
        _MetallicGlossMap("Metallic", 2D) = "white" {}
        _Metallic("Metallic", Range(0,1)) = 1
        _Glossiness("Smoothness", Range(0,1)) = 1

        // Ambient Occlusion Map
        _OcclusionMap("Occlusion", 2D) = "white" {}
        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0

        // Emission
        _EmissionMap("Emission Map", 2D) = "white" {}
        [HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)

        // Dithering
        _NoiseScale("Dithering Scale", Range(0,0.2)) = 0.001

        // Specular Lightmap Occlusion
        _SpecularLightmapOcclusion("Specular Lightmap Occlusion Scale", Range(0,1)) = 1

        // Tessellation and Heightmap
        _Tess("Tessellation Amount", Range(1,50)) = 1
        _minDist("Minimum Distance", Float) = 1
        _maxDist("Maximum Distance", Float) = 5
        _ParallaxMap("Height Map", 2D) = "black" {}
        _Parallax("Height Scale", Range(0,1)) = 0.02

        // Hacks
        [HideInInspector] _texcoord("", 2D) = "white" {}
        [HideInInspector] __dirty("", Int) = 1
    }

    SubShader
    {
        Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
        Cull Back

        CGINCLUDE
        #include "UnityPBSLighting.cginc"
        #include "Lighting.cginc"
        #include "Tessellation.cginc"

        #pragma shader_feature _NORMALMAP
        #pragma shader_feature _EMISSION
        #pragma shader_feature _METALLICGLOSSMAP
        #pragma shader_feature _PARALLAXMAP
        #pragma shader_feature _OCCLUSIONMAP

        #pragma target 5.0

        #ifdef UNITY_PASS_SHADOWCASTER
            #undef INTERNAL_DATA
            #undef WorldReflectionVector
            #undef WorldNormalVector
            #define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
            #define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
            #define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
        #endif

        //Include the lighting model
        #include "StandardLightingModelDithered.cginc"

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_CBUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_CBUFFER_END

        ENDCG

        CGPROGRAM
        #pragma surface surf DitheredStandard fullforwardshadows tessellate:tessDistance vertex:vert
        ENDCG
    }
    Fallback "Diffuse"
    CustomEditor "XS_PBR_Editor"
}
