
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

		struct SurfaceOutputCustomLightingCustom
		{
			fixed3 Albedo;
			fixed3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			fixed Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _ColorTint;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform float4 _EmissionColor;
		uniform sampler2D _MetallicGlossMap;
		uniform float4 _MetallicGlossMap_ST;
		float _Glossiness;
		float _Metallic;
		float _NoiseScale;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{


			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			SurfaceOutputStandard s10 = (SurfaceOutputStandard ) 0;
			

			float3 dither = (ditherNoiseFuncHigh(i.uv_texcoord.xy) - 0.5) * 2 * _NoiseScale;

			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			s10.Albedo = ( _ColorTint * tex2D( _MainTex, uv_MainTex ) ).rgb;
			float2 uv_Normal = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			s10.Normal = WorldNormalVector( i, UnpackNormal( tex2D( _BumpMap, uv_Normal ) ));
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			s10.Emission = ( tex2D( _EmissionMap, uv_EmissionMap ) * _EmissionColor ).rgb;
			float2 uv_MetallicGlossMap = i.uv_texcoord * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
			float4 tex2DNode2 = tex2D( _MetallicGlossMap, uv_MetallicGlossMap );
			s10.Metallic = tex2DNode2.r * _Metallic;
			
			s10.Smoothness = tex2DNode2.a * _Glossiness;
			float3 vNormalWsDdx = ddx( i.worldNormal.xyz );
    		float3 vNormalWsDdy = ddy( i.worldNormal.xyz );
    		float flGeometricRoughnessFactor = pow( saturate( max( dot( vNormalWsDdx.xyz, vNormalWsDdx.xyz ), dot( vNormalWsDdy.xyz, vNormalWsDdy.xyz ) ) ), 0.333 );
			s10.Smoothness= min( s10.Smoothness, 1.0 - flGeometricRoughnessFactor ); // Ensure we don’t double-count roughness if normal map encodes geometric roughness
			
			s10.Occlusion = 1.0;
			data.light = gi.light;

			UnityGI gi10 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g10 = UnityGlossyEnvironmentSetup( s10.Smoothness, data.worldViewDir, s10.Normal, float3(0,0,0));
			gi10 = UnityGlobalIllumination( data, s10.Occlusion, s10.Normal, g10 );
			#endif

			float3 surfResult10 = LightingStandard ( s10, viewDir, gi10 ).rgb;
			surfResult10 += s10.Emission;
			surfResult10 += (dither * data.atten);

			c.rgb = surfResult10;
			c.a = _ColorTint.a;
			return c;
		}
