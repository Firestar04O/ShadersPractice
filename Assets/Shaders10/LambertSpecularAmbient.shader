Shader "Custom/LambertSpecularAmbient"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _SpecColor("Specular Color", Color) = (1,1,1,1)
        _Shininess("Brillo", Range(8,256)) = 32
        _AmbientIntensity("Intensidad Ambiental", Range(0,1)) = 0.3
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            Name "LambertSpecularAmbient"
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
                float3 positionWS : WORLD_POSITION;
            };

            float4 _Color;
            float4 _SpecColor;
            float _Shininess;
            float _AmbientIntensity;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light mainLight = GetMainLight();
                half3 normal = normalize(IN.normalWS);
                half3 lightDir = normalize(-mainLight.direction);
                half3 viewDir = normalize(GetWorldSpaceViewDir(IN.positionWS));

                // Difuso (Lambert)
                half NdotL = saturate(dot(normal, lightDir));
                half3 diffuse = _Color.rgb * NdotL * mainLight.color.rgb;

                // Especular (Blinn-Phong)
                half3 halfDir = normalize(lightDir + viewDir);
                half NdotH = saturate(dot(normal, halfDir));
                half3 specular = _SpecColor.rgb * pow(NdotH, _Shininess) * mainLight.color.rgb;

                // Ambiental
                half3 ambient = _Color.rgb * _AmbientIntensity;

                return half4(diffuse + specular + ambient, 1);
            }
            ENDHLSL
        }
    }
}