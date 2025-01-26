using System.Collections.Generic;
using UnityEngine;

public class BoidsBehavior : MonoBehaviour
{
    [SerializeField] private List<Rigidbody> _boids = null;
    [SerializeField] private Transform _target = null;

    [Space]
    [SerializeField] private float _speed = 2.0f;
    [SerializeField] private float _keepDirectionWeight = 1.0f;
    [SerializeField] private float _followWeight = 1.0f;
    [SerializeField] private float _followDistWeight = 1.0f;
    [SerializeField] private float _seperateWeight = 1.0f;
    [SerializeField] private float _seperationDist = 1.0f;
    [SerializeField] private float _alignWeight = 1.0f;
    [SerializeField] private float _alignAverageDist = 1.0f;

    void Update()
    {
        foreach (Rigidbody boid in _boids)
        {
            UpdateBoid(boid);
        }
    }

    private void UpdateBoid(Rigidbody boid)
    {
        Vector3 follow = FollowBehavior(boid);
        Vector3 seperate = SeperationBehavior(boid);
        Vector3 align = AlignBehavior(boid);
        Vector3 direction = boid.linearVelocity * _keepDirectionWeight * Time.deltaTime;
        direction += follow * _followWeight * _speed;
        direction += seperate * _seperateWeight * _speed;
        direction += align * _alignWeight * _speed;
        boid.linearVelocity = direction;
        boid.transform.GetChild(0).LookAt(boid.transform.GetChild(0).position + direction);
    }

    private Vector3 FollowBehavior(Rigidbody boid)
    {
        Vector3 diff = _target.position - boid.position;
        //diff /= _followDistWeight / diff.magnitude;
        return diff.normalized;
    }

    private Vector3 SeperationBehavior(Rigidbody boid)
    {
        Vector3 seperation = Vector3.zero;
        int count = 0;
        foreach (Rigidbody otherBoid in _boids)
        {
            if (otherBoid == boid)
                continue;

            Vector3 diff = boid.position - otherBoid.position;
            float dist = diff.sqrMagnitude;
            if (dist < _seperationDist * _seperationDist)
            {
                seperation += diff.normalized;
                count++;
            }
        }
        if (count == 0)
            return Vector3.zero;
        return seperation / count;
    }

    private Vector3 AlignBehavior(Rigidbody boid)
    {
        Vector3 align = Vector3.zero;
        int count = 0;
        foreach (Rigidbody otherBoid in _boids)
        {
            if (otherBoid == boid)
                continue;

            Vector3 diff = otherBoid.position - boid.position;
            float dist = diff.sqrMagnitude;
            align += otherBoid.linearVelocity * (_alignAverageDist / dist);
            count++;
        }
        if (count == 0)
            return Vector3.zero;
        return align / count;
    }
}
