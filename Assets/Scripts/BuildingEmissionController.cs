using UnityEngine;
using System.Collections.Generic;

public class BuildingEmissionController : MonoBehaviour
{
    public DayNightCycle dayNightCycle;
    public List<Renderer> renderObjects = new List<Renderer>();
    private List<Material> materials = new List<Material>();

    [Header("Configuración de Emisión")]
    public Color emissionColor = new Color(1f, 0.8f, 0.6f);
    public float maxEmission = 2f;

    void Start()
    {
        GetMaterialCopies();
    }

    void GetMaterialCopies()
    {
        foreach (var r in renderObjects)
        {
            if (r == null) continue;
            Material mat = new Material(r.sharedMaterial);
            r.material = mat;
            materials.Add(mat);
        }
    }

    void Update()
    {
        if (dayNightCycle == null) return;

        // Obtener intensidad actual del sol (0 = noche, 1 = día)
        float sunIntensity = dayNightCycle.curvaIntensidad.Evaluate(dayNightCycle.ObtenerHoraActual() / 24f);

        float emissionFactor = Mathf.Clamp01(1 - sunIntensity);
        foreach (var mat in materials)
        {
            mat.EnableKeyword("_EMISSION");
            mat.SetColor("_EmissionColor", emissionColor * emissionFactor * maxEmission);
        }
    }
}