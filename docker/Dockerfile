FROM fedora:22
MAINTAINER Jianwei Hou, jhou@redhat.com

RUN dnf install -y ceph ceph-deploy ceph-radosgw hostname openssh kernel

ADD init.sh /

ENTRYPOINT /init.sh
