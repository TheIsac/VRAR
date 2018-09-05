﻿Shader "Custom/Bloom"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

CGINCLUDE
#include "UnityCG.cginc" 
	sampler2D _MainTex; 
	float4 _MainTex_TexelSize; 


	struct VertexData {
		float4 vertex : POSITION; 
		float4 uv : TEXCOORD0; 
	};

	struct Interpolators {
		float4 pos : SV_POSITION; 
		float2 uv : TEXCOORD0; 
	};

	Interpolators Vert(VertexData v) {
		Interpolators i; 
		i.pos = UnityObjectToClipPos(v.vertex); 
		i.uv = v.uv; 
		return i; 
	}

	half3 Sample(float2 uv) {
		return tex2D(_MainTex, uv).rbg; 
	}

	half3 SampleBox(float2 uv, float delta) {
		float4 o = _MainTex_TexelSize.xyxy * float2(-delta, delta).xxyy;
		half3 s =
			Sample(uv + o.xy) + Sample(uv + o.zy) +
			Sample(uv + o.xy) + Sample(uv + o.zw); 
		return s * 0.25f; 
	}

	ENDCG

	SubShader
	{
		// No culling or depth
		Cull Off 
		ZTest Always
		ZWrite Off 

		Pass
		{
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			half4 Frag(Interpolators i) : SV_Target{
				return half4 (SampleBox(i.uv, 1),1); 
			}
		ENDCG
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			half4 Frag(Interpolators i) : SV_Target{
				return half4 (SampleBox(i.uv, 0.5), 1);
			}
		
			ENDCG
		}
	}
}
