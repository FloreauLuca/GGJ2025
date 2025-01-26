using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ObjectToRayMarching : MonoBehaviour
{
    [SerializeField] private Transform[] _spheres;
    [SerializeField] private Transform _torus;
    private Material _material;

    void Awake()
    {
        _material = GetComponent<Renderer>().sharedMaterial;
    }

    void Update()
    {
        List<Vector4> spheresPos = new List<Vector4>();
        List<float> spheresRad = new List<float>();
        for (int i = 0; i < _spheres.Length; i++)
        {
            spheresPos.Add(_spheres[i].position);
            spheresRad.Add(_spheres[i].lossyScale.x);
        }
        _material.SetVectorArray("_SpheresPos", spheresPos);
        _material.SetFloatArray("_SpheresRadius", spheresRad);
        //_material.SetVector("_SpherePos", _spheres[0].position);
        //_material.SetFloat("_SphereRadius", _spheres[0].lossyScale.x);
        _material.SetInt("_SphereCount", _spheres.Length);
    }
}
