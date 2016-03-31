FROM fedora:22
MAINTAINER Jianwei Hou, jhou@redhat.com

RUN dnf install -y ceph ceph-deploy ceph-radosgw hostname openssh

ADD pre.sh /
ADD deploy.sh /

RUN /pre.sh

ENTRYPOINT /deploy.sh
