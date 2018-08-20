using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using System;

public class XS_PBR_Editor : ShaderGUI
{
    private static class Styles
    {
        public static GUIContent version = new GUIContent("v1.2", "The currently installed version.");
        public static GUIContent mainTex = new GUIContent("Albedo", "The Albedo/Diffuse texture.");
        public static GUIContent bumpTex = new GUIContent("Normal", "");
        public static GUIContent metallicTex = new GUIContent("Metallic Map", "");
        public static GUIContent occlusionTex = new GUIContent("Occlusion Map", "");
        public static GUIContent emissionTex = new GUIContent("Emission Map", "");
        public static GUIContent heightMapTex = new GUIContent("Height Map", "");
    }

    MaterialProperty albedoMap;
    MaterialProperty albedoColor;
    MaterialProperty bumpMap;
    MaterialProperty metallicMap;
    MaterialProperty metallic;
    MaterialProperty gloss;
    MaterialProperty occlusionMap;
    MaterialProperty occlusionStrength;
    MaterialProperty emissionMap;
    MaterialProperty emissionColor;
    MaterialProperty noiseScale;
    MaterialProperty sloScale;

    public override void OnGUI(MaterialEditor m_MaterialEditor, MaterialProperty[] props)
    {
        Material material = m_MaterialEditor.target as Material;
        {
            //Find all the properties within the shader
            albedoMap = ShaderGUI.FindProperty("_MainTex", props);
            albedoColor = ShaderGUI.FindProperty("_Color", props);
            bumpMap = ShaderGUI.FindProperty("_BumpMap", props);
            metallicMap = ShaderGUI.FindProperty("_MetallicGlossMap", props);
            metallic = ShaderGUI.FindProperty("_Metallic", props);
            gloss = ShaderGUI.FindProperty("_Glossiness", props);
            occlusionMap = ShaderGUI.FindProperty("_OcclusionMap", props);
            occlusionStrength = ShaderGUI.FindProperty("_OcclusionStrength", props);
            emissionMap = ShaderGUI.FindProperty("_EmissionMap", props);
            emissionColor = ShaderGUI.FindProperty("_EmissionColor", props);
            noiseScale = ShaderGUI.FindProperty("_NoiseScale", props);
            sloScale = ShaderGUI.FindProperty("_SpecularLightmapOcclusion", props);
        }

        EditorGUI.BeginChangeCheck();
        {
            int startingIndentLevel = EditorGUI.indentLevel;
            GUILayout.Label("MAIN SETTINGS", new GUIStyle(EditorStyles.miniLabel)
            {
                wordWrap = true,
                fontSize = 12
            });
            m_MaterialEditor.TexturePropertySingleLine(Styles.mainTex, albedoMap, albedoColor);
            EditorGUI.indentLevel += 1;
            m_MaterialEditor.TextureScaleOffsetProperty(albedoMap);
            EditorGUI.indentLevel -= 1;
            EditorGUILayout.Space();

            if (EditorGUI.EndChangeCheck())
            {
                emissionMap.textureScaleAndOffset = albedoMap.textureScaleAndOffset;
            }
            m_MaterialEditor.TexturePropertySingleLine(Styles.bumpTex, bumpMap);
            EditorGUI.indentLevel += 1;
            m_MaterialEditor.TextureScaleOffsetProperty(bumpMap);
            EditorGUI.indentLevel -= 1;
            EditorGUILayout.Space();

            m_MaterialEditor.TexturePropertySingleLine(Styles.metallicTex, metallicMap, metallic);
            EditorGUI.indentLevel += 1;
            m_MaterialEditor.ShaderProperty(gloss, gloss.displayName, 1);
            m_MaterialEditor.TextureScaleOffsetProperty(metallicMap);
            EditorGUI.indentLevel -= 1;

            EditorGUILayout.Space();
            m_MaterialEditor.TexturePropertySingleLine(Styles.occlusionTex, occlusionMap, occlusionStrength);
            EditorGUI.indentLevel += 1;
            m_MaterialEditor.TextureScaleOffsetProperty(occlusionMap);
            EditorGUI.indentLevel -= 1;

            EditorGUILayout.Space();
            m_MaterialEditor.TexturePropertySingleLine(Styles.emissionTex, emissionMap, emissionColor);

            EditorGUILayout.Space();
            EditorGUILayout.Space();
            GUILayout.Label("DITHER/LIGHTMAP SETTINGS", new GUIStyle(EditorStyles.miniLabel)
            {
                wordWrap = true,
                fontSize = 12
            });

            EditorGUI.indentLevel += 1;
            m_MaterialEditor.ShaderProperty(noiseScale, noiseScale.displayName);
            m_MaterialEditor.ShaderProperty(sloScale, "Lightmap Occlusion Scale");
            EditorGUI.indentLevel -= 1;

            SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap"));
            SetKeyword(material, "_METALLICGLOSSMAP", material.GetTexture("_MetallicGlossMap"));
            SetKeyword(material, "_PARALLAXMAP", material.GetTexture("_ParallaxMap"));
            SetKeyword(material, "_EMISSION", material.GetTexture("_EmissionMap"));

            EditorGUI.indentLevel = startingIndentLevel;
        }
        DoFooter();
    }
    void DoFooter()
    {
        GUILayout.Label(Styles.version, new GUIStyle(EditorStyles.centeredGreyMiniLabel)
        {
            alignment = TextAnchor.MiddleCenter,
            wordWrap = true,
            fontSize = 12
        });
    }

    static void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
        {
            m.EnableKeyword(keyword);
        }
        else
        {
            m.DisableKeyword(keyword);
        }
    }
}


