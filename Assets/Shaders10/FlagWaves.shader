Shader "Custom/FlagWaves"
{
    Properties
    {
        _FlagTex("Flag Texture", 2D) = "white" {}
        _SpecColor("Specular Color", Color) = (1,1,1,1)
        _Shininess("Shininess", Range(8,256)) = 32
        _AmbientIntensity("Ambient Intensity", Range(0,2)) = 0.35
        _WaveAmplitude("Wave Amplitude", Range(0,0.5)) = 0.05
        _WaveFrequency("Wave Frequency", Range(0,10)) = 2.0
        _WaveSpeed("Wave Speed", Range(0,5)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            Name "FlagWaves"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // Textures
            TEXTURE2D(_FlagTex);
            SAMPLER(sampler_FlagTex);

            float4 _FlagTex_ST;
            float4 _SpecColor;
            float _Shininess;
            float _AmbientIntensity;
            float _WaveAmplitude;
            float _WaveFrequency;
            float _WaveSpeed;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : NORMAL;
                float3 positionWS  : WORLD_POSITION;
                float2 uv          : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                // object-space pos
                float3 posOS = IN.positionOS.xyz;

                // Wave (based on object-space X coordinate and time)
                float t = _Time.y * _WaveSpeed;
                float wave = sin(posOS.x * _WaveFrequency + t) * _WaveAmplitude;
                // Optionally add a second wave for richness
                wave += sin(posOS.y * (_WaveFrequency * 0.6) + t * 1.3) * (_WaveAmplitude * 0.5);

                // apply displacement along the local Z axis (out-of-plane)
                posOS.z += wave;

                // transform displaced position to clip space
                OUT.positionHCS = TransformObjectToHClip(float4(posOS, 1.0));

                // Recompute normal: approximate by perturbing original normal with wave derivative
                float3 n = IN.normalOS;
                // small normal perturb (good enough for flag visual)
                n = normalize(n + float3(-cos(posOS.x * _WaveFrequency + t) * _WaveFrequency * _WaveAmplitude, 0, 0));

                OUT.normalWS = TransformObjectToWorldNormal(n);
                OUT.positionWS = TransformObjectToWorld(float4(posOS,1));
                OUT.uv = TRANSFORM_TEX(IN.uv, _FlagTex);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Main light
                Light mainLight = GetMainLight();

                half3 normal = normalize(IN.normalWS);
                half3 lightDir = normalize(-mainLight.direction);
                half3 viewDir = normalize(GetWorldSpaceViewDir(IN.positionWS));

                half3 texColor = SAMPLE_TEXTURE2D(_FlagTex, sampler_FlagTex, IN.uv).rgb;

                // Diffuse (Lambert)
                half NdotL = saturate(dot(normal, lightDir));
                half3 diffuse = texColor * NdotL * mainLight.color.rgb;

                // Specular (Blinn-Phong)
                half3 halfDir = normalize(lightDir + viewDir);
                half NdotH = saturate(dot(normal, halfDir));
                half3 specular = _SpecColor.rgb * pow(NdotH, _Shininess) * mainLight.color.rgb;

                // Ambient (enhanced)
                half3 ambient = texColor * _AmbientIntensity;

                half3 color = saturate(diffuse + specular + ambient);
                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}