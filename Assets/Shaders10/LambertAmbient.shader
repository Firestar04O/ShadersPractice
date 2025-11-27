Shader "Custom/LambertAmbientURP"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _AmbientIntensity("Intensidad Ambiental", Range(0,1)) = 0.3
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            Name "LambertAmbient"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : NORMAL;
            };

            float4 _Color;
            float _AmbientIntensity;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Obtener luz direccional principal de URP
                Light mainLight = GetMainLight();

                // Normalizar normal y dirección de la luz
                half3 normal = normalize(IN.normalWS);
                half3 lightDir = normalize(mainLight.direction);

                // Cálculo difuso (Lambert)
                half NdotL = saturate(dot(normal, -lightDir)); // negativo porque la luz apunta en dirección opuesta
                half3 diffuse = _Color.rgb * NdotL * mainLight.color.rgb;

                // Luz ambiental simple
                half3 ambient = _Color.rgb * _AmbientIntensity;

                return half4(diffuse + ambient, 1);
            }
            ENDHLSL
        }
    }
}