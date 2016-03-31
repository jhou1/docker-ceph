#!/bin/bash

HOSTNAME=`hostnamectl set-hostname ceph-mon`
INTERNAL_IP=`hostname -i`
HOME_DIR=/home/ceph
SSH_KEY_DIR=${HOME_DIR}/.ssh
RNG=`uuidgen -r | cut -d '-' -f 5`
CEPH_CLUSTER_DIR=/root/ceph-cluster

# Add ip and hostname mapping to /etc/hosts
echo "${INTERNAL_IP} ${HOSTNAME}" >> /etc/hosts

# Configure user
useradd -d /home/ceph -m ceph -p ${RNG}
echo "ceph ALL = (root) NOPASSWD:ALL\nDefaults:ceph !requiretty\n" >> /etc/sudoers

# Configure ssh
mkdir /home/ceph/.ssh
ssh-keygen -f ${SSH_KEY_DIR}/id_rsa -P ${RNG}
echo "Host ${HOSTNAME}\n\tHostname ${HOSTNAME}\n\tUser ceph\n\tIdentityFile ${SSH_KEY_DIR}/id_rsa" >> /etc/ssh/ssh_config
cat ${SSH_KEY_DIR}/id_rsa.pub > ${SSH_KEY_DIR}/.authorized_keys
