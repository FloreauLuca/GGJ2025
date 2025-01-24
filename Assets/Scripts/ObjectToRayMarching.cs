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
        for (int i = 0; i < _spheres.Length; i++)
        {
            spheresPos.Add(_spheres[i].position);
        }
        _material.SetVectorArray("_SpheresPos", spheresPos);
        _material.SetVector("_SpherePos", _spheres[0].position);
        _material.SetFloat("_SphereRadius", 0.25f);
        _material.SetInt("_SphereCount", _spheres.Length);
    }
}
