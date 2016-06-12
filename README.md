CephFS server pod for OpenShift testing.

# Making CephFS server docker image
Copied from https://github.com/kubernetes/kubernetes/tree/master/test/images/volumes-tester/ceph. Made a few changes to meet our testing requirements.

# Creating CephFS server pod
Edit `scc.yml`, replace `YOUR_USERNAME` with your login name, then:

```
oc create -f scc.yml
oc create -f cephfs-server.json
oc create -f cephfs-secret.yml
```

## Verifying your CephFS server is functional

Run `oc exec cephfs-server -- ceph health`, when you see **HEALTH_OK**, your server pod is ready. If you haven't seen it, wait a short time until it is successfully deployed.

# Creating Persistent Volume and Claim
Run `oc get pod cephfs-server -o yaml | grep podIP`, the ip of the pod is then used for you to access the cephfs server.

Assume your service ip is `10.1.0.1`

```
sed -i s/#POD_IP#/10.1.0.1/ pv-rwo.json
oc create -f pv-rwo.json
oc create -f pvc-rwo.json
```

Run `oc get pv;oc get pvc`, you should see them Bound together.

# Creating tester pod

Create the pod: `oc create -f pod.json`, then run `oc get pods`, you should see the pod is `Running`.
