Shader "HDRenderPipeline/Decal"
{
    Properties
    {      
        _BaseColorMap("BaseColorMap", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}     // Tangent space normal map
		_MaskMap("MaskMap", 2D) = "white" {}    
		_HeightMap("HeightMap", 2D) = "white" {}    
        // Caution: Default value of _HeightAmplitude must be (_HeightMax - _HeightMin) * 0.01
        [HideInInspector] _HeightAmplitude("Height Amplitude", Float) = 0.02 // In world units. This will be computed in the UI.
        _HeightMin("Heightmap Min", Float) = -1
        _HeightMax("Heightmap Max", Float) = 1
        _HeightCenter("Height Center", Range(0.0, 1.0)) = 0.5 // In texture space

		_DecalBlend("_DecalBlend", Range(0.0, 1.0)) = 0.5
    }

    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal
    //#pragma enable_d3d11_debug_symbols

    //-------------------------------------------------------------------------------------
    // Variant
    //-------------------------------------------------------------------------------------
	#pragma shader_feature _COLORMAP
	#pragma shader_feature _NORMALMAP
	#pragma shader_feature _MASKMAP
	#pragma shader_feature _HEIGHTMAP


    //-------------------------------------------------------------------------------------
    // Define
    //-------------------------------------------------------------------------------------
	#define UNITY_MATERIAL_DECAL // do we need this now that Material.hlsl is not getting included?


    //-------------------------------------------------------------------------------------
    // Include
    //-------------------------------------------------------------------------------------

    #include "ShaderLibrary/Common.hlsl"
    #include "ShaderLibrary/Wind.hlsl"
    #include "../../ShaderPass/FragInputs.hlsl"
    #include "../../ShaderPass/ShaderPass.cs.hlsl"


    //-------------------------------------------------------------------------------------
    // variable declaration
    //-------------------------------------------------------------------------------------

    #include "DecalProperties.hlsl"

    // All our shaders use same name for entry point
    #pragma vertex Vert
    #pragma fragment Frag

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "DBuffer"  // Name is not used
            Tags { "LightMode" = "DBuffer" } // This will be only for opaque object based on the RenderQueue index

			// need to optimize this and use proper Cull and ZTest modes for cases when decal geometry is clipped by camera 
            Cull Off
			ZWrite Off
			ZTest Always

			HLSLPROGRAM

			#define SHADERPASS SHADERPASS_DBUFFER
			#include "../../ShaderVariables.hlsl"
			#include "Decal.hlsl"
			#include "ShaderPass/DecalSharePass.hlsl"		
			#include "DecalData.hlsl"
			#include "../../ShaderPass/ShaderPassDBuffer.hlsl"

            ENDHLSL
        }
	}
    CustomEditor "Experimental.Rendering.HDPipeline.DecalUI"
}