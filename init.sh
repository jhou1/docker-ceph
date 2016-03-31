#!/bin/bash

HOSTNAME=ceph-mon
INTERNAL_IP=`hostname -i`
HOME_DIR=/home/ceph
SSH_KEY_DIR=${HOME_DIR}/.ssh
RNG=`uuidgen -r | cut -d '-' -f 5`
CEPH_CLUSTER_DIR=/root/ceph-cluster

set_hostname() {
    # Can not use hostnamectl due to https://github.com/docker/docker/issues/7459
    echo ${HOSTNAME} > /etc/hostname
    hostname ${HOSTNAME}
}


set_passwordless() {
    # Configure user
    useradd -d /home/ceph -m ceph -p ${RNG}
    echo "ceph ALL = (root) NOPASSWD:ALL\nDefaults:ceph !requiretty\n" >> /etc/sudoers

    # Configure ssh
    mkdir /home/ceph/.ssh
    ssh-keygen -f ${SSH_KEY_DIR}/id_rsa -P ${RNG}
    echo "Host ${HOSTNAME}\n\tHostname ${HOSTNAME}\n\tUser ceph\n\tIdentityFile ${SSH_KEY_DIR}/id_rsa" >> /etc/ssh/ssh_config
    cat ${SSH_KEY_DIR}/id_rsa.pub > ${SSH_KEY_DIR}/.authorized_keys
}


deploy_ceph() {
    mkdir /storage01 /storage02 /storage03 ${CEPH_CLUSTER_DIR}
    cd ${CEPH_CLUSTER_DIR}

    # Add ip and hostname mapping to /etc/hosts
    echo "${INTERNAL_IP} ${HOSTNAME}" >> /etc/hosts

    # Create new deployment
    ceph-deploy new ${HOSTNAME}

    # Set osd_crush_chooseleaf_type for one-node ceph
    echo "osd_crush_chooseleaf_type = 0" >> ${CEPH_CLUSTER_DIR}/ceph.conf

    ceph-deploy mon create-initial

    # Prepare and activate storage
    ceph-deploy osd prepare ${HOSTNAME}:/storage01 ${HOSTNAME}:/storage02 ${HOSTNAME}:/storage03
    ceph-deploy osd activate ${HOSTNAME}:/storage01 ${HOSTNAME}:/storage02 ${HOSTNAME}:/storage03

    # Gather keys
    ceph-deploy admin ${HOSTNAME}

    chmod 644 /etc/ceph/ceph.client.admin.keyring
    ceph health

}

create_img() {
    rbd create disk01 --size 5120
    rbd ls -l
    rbd map disk01
    rbd showmapped
}

wait_for_health_ok() {
    ok=false
    while [ ${ok} != true ]
    do
        sleep 10
        ceph health | grep HEALTH_OK
        [ $? == 0 ] && ok=true
    done
}

set_hostname
set_passwordless
deploy_ceph

# Once ceph is healthy, create image
wait_for_health_ok
create_img

while true
do
    sleep 30
done
