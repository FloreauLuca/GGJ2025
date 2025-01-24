using UnityEngine;

[ExecuteInEditMode]
public class ObjectToRayMarching : MonoBehaviour
{
    [SerializeField] private Transform _sphere;
    [SerializeField] private Transform _torus;
    private Material _material;

    void Awake()
    {
        _material = GetComponent<Renderer>().material;
    }

    void Update()
    {
        _material.SetFloat("_SphereSize", _sphere.lossyScale.x);
        _material.SetVector("_SpherePos", _sphere.position);
    }
}
