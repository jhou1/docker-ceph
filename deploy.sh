#!/bin/bash

# Deploy ceph all-in-one
HOSTNAME=`hostnamectl set-hostname ceph-mon`
CEPH_CLUSTER_DIR=/root/ceph-cluster

mkdir /storage01 /storage02 /storage03
ceph-deploy osd prepare ${HOSTNAME}:/storage01 ${HOSTNAME}:/storage02 ${HOSTNAME}:/storage03
ceph-deploy osd activate ${HOSTNAME}:/storage01 ${HOSTNAME}:/storage02 ${HOSTNAME}:/storage03
ceph-deploy admin ${HOSTNAME} ${CEPH_CLUSTER_DIR}

chmod 644 /etc/ceph/ceph.client.admin.keyring
ceph health
