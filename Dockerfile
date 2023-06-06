# Centos base images
FROM centos:centos7

# Update currently installed package and install tcpdump 
RUN yum -y update && yum -y install tcpdump

CMD ["sleep", "10m"]
