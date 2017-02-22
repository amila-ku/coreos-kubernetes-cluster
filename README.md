# k8-terraform
This projects creates with autoscaling etcd, master and worker with 3 node etcd and master clusters. 


## How to create cluster
**export aws keys**

export AWS_ACCESS_KEY_ID='xxxxxxxxxxxxxxxxxxxx'

export AWS_SECRET_ACCESS_KEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxx'

**check what resources would be created:**
make plan to 

**create resources:**
make apply


###Issues Observed

* flannel needs to point to remote etcd since etcd is seperated from master.
* master ELB should listed on TCP 443 instead of HTTPS
* use --leader-elect option to make sure one instance of schedular and controller manager is available at once.


This borrows ideas from Kelsey Hightower and Refers Ross Kinders implementation CoreOS official implementation guides

Kelsey Hightower Repo:
https://github.com/kelseyhightower/kubernetes-the-hard-way/

CoreOS Guide: 
https://coreos.com/kubernetes/docs/latest/getting-started.html

ETCD by Ross Kinders: 
https://github.com/crewjam/etcd-aws
