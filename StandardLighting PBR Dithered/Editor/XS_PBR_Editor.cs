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
		  public static GUIContent maintex = new GUIContent("Albedo", "The Albedo/Diffuse texture.");
		  public static GUIContent bumptex = new GUIContent("Normal", "");
		  public static GUIContent metallictex = new GUIContent("Metallic Map", "");
		  public static GUIContent occlusiontex = new GUIContent("Occlusion Map", "");
		  public static GUIContent emissiontex = new GUIContent("Emission Map", "");
		  public static GUIContent heightmaptex = new GUIContent("Height Map", "");
	}

	MaterialProperty maintex;
	MaterialProperty color;
	MaterialProperty bumpmap;
	MaterialProperty metallicmap;
	MaterialProperty metallic;
	MaterialProperty gloss;
	MaterialProperty occlusionmap;
	MaterialProperty occlusionstrength;
	MaterialProperty emissionmap;
	MaterialProperty emissioncol;
	MaterialProperty noisescale;
	MaterialProperty slo;
	MaterialProperty tess;
	MaterialProperty mindist;
	MaterialProperty maxdist;
	MaterialProperty heightmap;
	MaterialProperty displacement;

	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
		 Material material = materialEditor.target as Material;
        {
            //Find all the properties within the shader
            maintex = ShaderGUI.FindProperty("_MainTex", props);
			 color = ShaderGUI.FindProperty("_Color", props);
			  bumpmap = ShaderGUI.FindProperty("_BumpMap", props);
			   metallicmap = ShaderGUI.FindProperty("_MetallicGlossMap", props);
			    metallic = ShaderGUI.FindProperty("_Metallic", props);
				 gloss = ShaderGUI.FindProperty("_Glossiness", props);
				  occlusionmap = ShaderGUI.FindProperty("_OcclusionMap", props);
				   occlusionstrength = ShaderGUI.FindProperty("_OcclusionStrength", props);
				    emissionmap = ShaderGUI.FindProperty("_EmissionMap", props);
					 emissioncol = ShaderGUI.FindProperty("_EmissionColor", props);
					  noisescale = ShaderGUI.FindProperty("_NoiseScale", props);
					   slo = ShaderGUI.FindProperty("_SpecularLightmapOcclusion", props);
					    tess = ShaderGUI.FindProperty("_Tess", props);
						 mindist = ShaderGUI.FindProperty("_minDist", props);
						  maxdist = ShaderGUI.FindProperty("_maxDist", props);
						   heightmap = ShaderGUI.FindProperty("_Heightmap", props);
						    displacement = ShaderGUI.FindProperty("_Displacement", props);
		}

		EditorGUI.BeginChangeCheck();
        {
			GUILayout.Label("MAIN SETTINGS", new GUIStyle(EditorStyles.miniLabel)
			{
					wordWrap = true,
					fontSize = 12
			});
					materialEditor.TexturePropertySingleLine(Styles.maintex, maintex, color);
					materialEditor.TexturePropertySingleLine(Styles.bumptex, bumpmap);
					materialEditor.TexturePropertySingleLine(Styles.metallictex, metallicmap);
					materialEditor.ShaderProperty(metallic, metallic.displayName, 2);
					materialEditor.ShaderProperty(gloss, gloss.displayName, 2);
					
                EditorGUILayout.Space();
					materialEditor.TexturePropertySingleLine(Styles.occlusiontex, occlusionmap);
					materialEditor.ShaderProperty(occlusionstrength, occlusionstrength.displayName, 2);
					
                EditorGUILayout.Space();
					materialEditor.TexturePropertySingleLine(Styles.emissiontex, emissionmap, emissioncol);
			
            EditorGUILayout.Space();
			GUILayout.Label("DITHER/LIGHTMAP SETTINGS", new GUIStyle(EditorStyles.miniLabel)
			{
					wordWrap = true,
					fontSize = 12
			});
					materialEditor.ShaderProperty(noisescale, noisescale.displayName, 2);
					materialEditor.ShaderProperty(slo, "Lightmap Occlusion Scale", 2);
			
        	EditorGUILayout.Space();
			GUILayout.Label("TESSELLATION SETTINGS", new GUIStyle(EditorStyles.miniLabel)
			{
					wordWrap = true,
					fontSize = 12
			});
					materialEditor.TexturePropertySingleLine(Styles.heightmaptex, heightmap);
					materialEditor.ShaderProperty(tess, tess.displayName,2);
					materialEditor.ShaderProperty(mindist, mindist.displayName,2);
					materialEditor.ShaderProperty(maxdist, maxdist.displayName,2);
					materialEditor.ShaderProperty(displacement, displacement.displayName,2);

		}
	DoFooter();
	}
	void DoFooter(){
			GUILayout.Label(Styles.version, new GUIStyle(EditorStyles.centeredGreyMiniLabel)
			{
				alignment = TextAnchor.MiddleCenter,
				wordWrap = true,
				fontSize = 12
			});		
		}
    }


