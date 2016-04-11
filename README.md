Ceph server container for OpenShift.

## Run the pod as a Ceph server

The Ceph server needs to run as privileged container, so before you start, you need to update OpenShift SCC to allow privileged containers, also you need to set the type of `runAsUser` to `RunAsAny` so that the init.sh could have access to deploy ceph.

1. Create the Ceph server pod, run `oc create -f ceph.json`

2. After pod is up and running, run `oc exec ceph-server ceph health`, you should see **HEALTH_OK**, that means ceph server is funcional. You may need to wait for a while before you see the result because it might take some time for the pod to finish deploying Ceph. After Ceph is deployed, a default `disk01` image will be created.

3. Get the base64 encoded keyring, run `oc exec ceph-server -- ceph-authtool -p /etc/ceph/ceph.client.admin.keyring | base64`, use the output as value of `key: ` in the rbd-secret.yaml

4. Create secret, run `oc create -f rbd-secret.yaml`

5. Run `oc get pod ceph-server | grep podIP`, the output this the IP of the pod inside the OpenShift cluster, update `pod.json` replace the host IP of `monitor` with your value.

6. Create the pod that has rbd mount, run `oc create -f pod.json`. Once the pod is created, you can able to verify the mount directory is operational.
