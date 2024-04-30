#### Kubernetes Learning


#### Creating EKS clusters

* Via terraform

https://developer.hashicorp.com/terraform/tutorials/aws/eks


* Install kubectl and make sure it matches the kubernetes version in EKS cluster

```
curl -LO https://dl.k8s.io/release/v1.27.0/bin/linux/amd64/kubectl

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client
```


* After cluster creation, get the kubeconfig file

```
aws eks update-kubeconfig --region region-code --name my-cluster
```

the config is created in ~/.kube/config

```
kubectl get svc`
```

* Can also get the kubeconfig via a role arn; this is useful for testing role:
```
aws eks update-kubeconfig --region eu-west-1 --name education --role-arn XXX
```

Use `kubectl auth can-i delete pods` for example to test the permissions of role from above ^; swap delete pods for other actions



#### Cluster Role, Role, Bindings

Cluster Role - applies to entire cluster
Cluster Role binding - Binds cluster role to a group
Role - applies to particular namespace
Role binding - Binds role to group


Create the roles / cluster roles separately using kubectl

Adjust the aws-auth configmap to map roles / users to specified groups


#### On Cluster access via EKS Access policies

The preferred way to manage EKS access is via Access Policies:

https://aws.amazon.com/blogs/containers/a-deep-dive-into-simplified-amazon-eks-access-management-controls/

https://aws.amazon.com/blogs/containers/a-deep-dive-into-simplified-amazon-eks-access-management-controls/


Note that, if using an IAM role as principal, the role would still need EKS permissions to access the AWS EKS dashboard in AWS Console

Default authentication mode is API_AND_CONFIGMAP but can set it to strictly API or CONFIGMAP only

Can also remove access for creator of cluster to not have admin priveleges

To view list of EKS access policies:
```
aws eks list-access-policies
```


To view access entries for an existing cluster:
```
aws eks list-access-entries --cluster-name <CLUSTER_NAME>
```



#### On API access via aws-auth configmap

https://aws.plainenglish.io/organizing-eks-permissions-for-users-and-roles-on-aws-09f8454a5bf5

https://repost.aws/knowledge-center/amazon-eks-cluster-access

https://medium.com/@radha.sable25/enabling-iam-users-roles-access-on-amazon-eks-cluster-f69b485c674f

https://docs.aws.amazon.com/eks/latest/userguide/auth-configmap.html


Example below adds the master account user and devs user to the systems:master group which has top-level access to the cluster
```
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::<ACCOUNT_ID>:role/node-group-2-eks-node-group-20240429140129184100000002
      username: system:node:{{EC2PrivateDNSName}}
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::<ACCOUNT_ID>:role/node-group-1-eks-node-group-20240429140129183200000001
      username: system:node:{{EC2PrivateDNSName}}
  mapUsers: |
    - groups:
      - system:masters
      userarn: arn:aws:iam::<ACCOUNT_ID>:root
    - groups:
      - system:masters
      userarn: arn:aws:iam::<ACCOUNT_ID>:user/devs
kind: ConfigMap
metadata:
  creationTimestamp: "2024-04-29T14:10:09Z"
  name: aws-auth
  namespace: kube-system
  resourceVersion: "7503"
  uid: a0256de9-ea6d-4b07-b1df-36691f3d7b53
```


* IAM best practices recommend that you grant permissions to roles instead of users


### View Kubernetes Resources in Management Console

To allow AWS console access to EKS resources, need to create appropriate permissions for IAM role and then add Role to the aws-auth configmap mapping:

https://docs.aws.amazon.com/eks/latest/userguide/view-kubernetes-resources.html#view-kubernetes-resources-permissions

https://stackoverflow.com/questions/70787520/your-current-user-or-role-does-not-have-access-to-kubernetes-objects-on-this-eks

https://stackoverflow.com/a/75244751


### Access svc via AWS Application Load Balancer

https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html

Need to install alb load balancer controller in cluster ...


https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v20.8.5/examples/eks_managed_node_group/main.tf