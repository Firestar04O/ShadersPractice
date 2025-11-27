Shader "Custom/TextureSpecularLambertAmbient"
{
    Properties
    {
        _MainTex("Textura", 2D) = "white" {}
        _SpecColor("Specular Color", Color) = (1,1,1,1)
        _Shininess("Brillo", Range(8,256)) = 32
        _AmbientIntensity("Intensidad Ambiental", Range(0,1)) = 0.3
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            Name "TextureSpecularLambertAmbient"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // 🔹 Includes correctos para URP
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD1;
                float3 positionWS  : TEXCOORD2;
                float2 uv          : TEXCOORD0;
            };

            // Propiedades
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            float4 _SpecColor;
            float _Shininess;
            float _AmbientIntensity;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Obtener la luz principal del URP
                Light mainLight = GetMainLight();

                half3 normal = normalize(IN.normalWS);
                half3 lightDir = normalize(-mainLight.direction);
                half3 viewDir = normalize(GetWorldSpaceViewDir(IN.positionWS));

                half3 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).rgb;

                // Difuso (Lambert)
                half NdotL = saturate(dot(normal, lightDir));
                half3 diffuse = texColor * NdotL * mainLight.color.rgb;

                // Especular (Blinn-Phong)
                half3 halfDir = normalize(lightDir + viewDir);
                half NdotH = saturate(dot(normal, halfDir));
                half3 specular = _SpecColor.rgb * pow(NdotH, _Shininess) * mainLight.color.rgb;

                // Ambiental
                half3 ambient = texColor * _AmbientIntensity;

                half3 finalColor = saturate(diffuse + specular + ambient);

                return half4(finalColor, 1.0);
            }
            ENDHLSL
        }
    }
}
