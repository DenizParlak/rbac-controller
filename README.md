# k8s-rbac

RBAC Controller

## Objective

To create user Jim in any group like 'QA' for kubernetes any cluster like 'shared' and give only Read access to this user across the cluster 'shared'.

- Generating the jim.key and kubeconfig

```bash
$ ./run-all.sh QA  
Shared cluster
Usage: ./run-all.sh <namespace> <user-group> <access-type>
Values for <user-group> : QA|FrontEnd|Backend
Values for <access-type> : R|RW

$ ./run-all.sh QA R

Shared cluster
-------------------------------
          Resetting previous changes           
-------------------------------
certificatesigningrequest.certificates.k8s.io "shared-QA-R-csr" deleted
clusterrole.rbac.authorization.k8s.io "role-shared-QA-R" deleted
clusterrolebinding.rbac.authorization.k8s.io "rolebinding-shared-QA-R" deleted
-------------------------------
          Client Cert Generation           
-------------------------------
Generating RSA private key, 4096 bit long modulus
.............................................................................++
...........................................................................++
e is 65537 (0x10001)
-------------------------------
          kubeconfig & jim.key generation          
-------------------------------
certificatesigningrequest.certificates.k8s.io/shared-QA-R-csr created
NAME                   AGE   SIGNERNAME                     REQUESTOR          CONDITION
shared-QA-R-csr   1s    kubernetes.io/legacy-unknown   kubernetes-admin   Pending
certificatesigningrequest.certificates.k8s.io/shared-QA-R-csr approved
NAME                   AGE   SIGNERNAME                     REQUESTOR          CONDITION
shared-QA-R-csr   3s    kubernetes.io/legacy-unknown   kubernetes-admin   Approved,Issued
clusterrole.rbac.authorization.k8s.io/role-shared-QA-R created
clusterrolebinding.rbac.authorization.k8s.io/rolebinding-shared-QA-R created
-------------------------------
          Share the following files with the QA
          ./shared//QA/kubeconfig
          ./shared//QA/jim.key

          Initialization Steps
          $ export KUBECONFIG=$PWD/kubeconfig

          $ kubectl config set-credentials jim \
            --client-key=$PWD/jim.key \
            --embed-certs=true
          
-------------------------------
```


- At the client workstation

```bash
$ ls kubeconfig jim.key
jim.key   kubeconfig

$ export KUBECONFIG=$PWD/kubeconfig

$ $ kubectl config set-credentials jim \
  >   --client-key=$PWD/jim.key \
  >   --embed-certs=true
  User "jim" set.

$ kubectl get pods -n monitoring
NAME                       READY   STATUS    RESTARTS   AGE
grafana-statefulset-0      1/1     Running   0          53m
prometheus-statefulset-0   2/2     Running   0          54m

$ kubectl get pods -n default    
No resources found.

$ kubectl get namespace  
Error from server (Forbidden): namespaces is forbidden: User "jim" cannot list resource "namespaces" in API group "" at the cluster scope

$ kubectl apply -f www.yaml
Error from server (Forbidden): error when creating "www.yaml": deployments.apps is forbidden: User "jim" cannot create resource "deployments" in API group "apps" in the namespace "kube-system"
Error from server (Forbidden): error when creating "www.yaml": services is forbidden: User "jim" cannot create resource "services" in API group "" in the namespace "kube-system"

$ kubectl delete pod prometheus-statefulset-0 -n monitoring                                                        
Error from server (Forbidden): pods "prometheus-statefulset-0" is forbidden: User "jim" cannot delete resource "pods" in API group "" in the namespace "monitoring"
```
