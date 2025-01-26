using UnityEngine;

public class EyFollowBehavior : MonoBehaviour
{
    [SerializeField] private float _speed = 5.0f;

    private Vector3 _target = Vector3.zero;

    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            _target = Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, 10.0f));
        }
        Vector3 dir = _target - transform.position;
        float dist = dir.magnitude;
        dir.Normalize();
        GetComponent<Rigidbody>().linearVelocity = dir * Mathf.Clamp(_speed, 0.0f, dist);
        Animator[] animators = GetComponentsInChildren<Animator>();
        foreach (Animator animator in animators)
        {
            animator.SetFloat("LookX", dir.x);
            animator.SetFloat("LookY", dir.y);
        }
    }
}
