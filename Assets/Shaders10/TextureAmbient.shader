Shader "Custom/TextureAmbientURP"
{
    Properties
    {
        _MainTex("Textura", 2D) = "white" {}
        _AmbientIntensity("Intensidad Ambiental", Range(0,1)) = 0.3
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            Name "TextureAmbient"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // === Macros modernas para texturas en URP ===
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float4 _MainTex_ST;
            float _AmbientIntensity;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half3 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).rgb;
                // Luz ambiental más visible: ilumina el color base
                half3 ambient = texColor * _AmbientIntensity;
                // Mezclar sumando (más intensidad -> más brillo)
                half3 finalColor = texColor + ambient;
                return half4(finalColor, 1);
            }
            ENDHLSL
        }
    }
}