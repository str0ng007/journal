# What is Argo CD

Argo CD is a declarative, GitOps continous delivery tool for Kubernetes. We will use the tool to manage our kubernetes deplolyment. It is a tool to automatically synchronize the cluster to the desired state defined in a Git repository.

![Architecture](images/argocd_architecture.png)

# Installation

## Requirements
* Kubernetes cluster and `kubectl`
* Helm
* Git Repo

## Creating a Helm Chart
Let's use Helm to install ArgoCD with the chart from [argoproj/argo-helm](https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd). Our setup needs to set a custom values and we'll create our own Helm "umbrella" chart that pulls in the original Argo CD chart as dependency.

Create a directory and populate with `values` below.
```
$ mkdir -p charts/argo-cd
```
Create `Chart.yaml` under `charts/argo-cd`
```
apiVersion: v2
name: argo-cd
version: 1.0.0
dependencies:
  - name: argo-cd
    version: 2.11.0
    repository: https://argoproj.github.io/argo-helm
charts/argo-cd/values.yaml
argo-cd:
  installCRDs: false
  global:
    image:
      tag: v1.8.1
  dex:
    enabled: false
  server:
    extraArgs:
      - --insecure
    config:
      repositories: |
        - type: helm
          name: stable
          url: https://charts.helm.sh/stable
        - type: helm
          name: argo-cd
          url: https://argoproj.github.io/argo-helm
```
Before we install the chart, we need to generate a Chart.lock file, We do this so that our dependency (the original argo-cd chart can be rebuilt.
```
$ helm repo add argo-cd https://argoproj.github.io/argo-helm
$ helm dep update charts/argo-cd/
```
This will generate two files:
```
• Chart.lock
• charts/argo-cd-2.xx.x.tgz
```
the tgz file is the downloaded dependency and not required in our Git repo. Argo CD can download the dependencies by itself. We can exclude it by creating a .gitignore file in the chart dir.

```
$ echo "charts/" > charts/argo-cd/.gitignore
```
The chart is ready and we can push it to our Git repo.
```
$ git add charts/argo-cd
$ git commit -m 'Initial version'
$ git push
```
## Installing Argo CD Helm Chart
Later on we'll let Argo CD manage itself so what we can perform updates by modifying files inside our Git repo. But for the initial bootstrap we have to install it manually

```
$ helm install argo-cd charts/argo-cd/
```
## Accessing the Web UI
The Helm chart doesn't install an Ingress by default, so to access the Argo CD Web UI, we have to port-forward to the service (Let's add Ingress later)
```
$ kubectl port-forward svc/argo-cd-argocd-server 8080:443
```
We can now access `ArgoCD` UI via `http://localhost:8080`

The default username is `admin`. The password is auto-generated and defaults to the pod name of the Argo CD server pod. We can get it with..
```
$ kubectl get pods -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```
Applications can be added through the Web UI but since we want to manage everything declaratively, we'll write Application manifests.

## The root App
To add an application to Argo CD, we need to add an Application resource to Kubernetes. It specifies the Git repository and the file path under which to file the manifests.

## Create the root app chart
For the root app we'll create a Helm chart that has Application manifests as templates. We create it in an apps directory and put a `Chart.yaml` file and an empty `values.yaml` file in it.

```
$ mkdir -p apps/templates
$ touch apps/values.yaml
```
Create `apps/Chart.yaml` with the values below.

```
apiVersion: v2
name: root
version: 1.0.0
```
We create the `Application` manifest for our root application in `apps/templates/root.yaml`. This allows us to do any updates to the root application itself through Argo CD.
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  project: default
  source:
    path: apps/
    repoURL: https://github.com/arthurk/argocd-example-install.git
    targetRevision: HEAD
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
> NOTE: We set automate sync to false by removing syncPolicy block and to the syncing manually

The above `Application` watches the Helm chart under `apps/` (our root application) and sync it if changes were detected.

How does Argo CD know our application is a Helm chart? It looks for a `Chart.yaml` file under path in the Git repository. If present, it will check the apiVersion inside it. For apiVersion: v1 it uses Helm 2, for apiVersion: v2 it uses Helm 3 to render the chart.

> NOTE: Argo CD will not use helm install to install charts. It will render the chart with helm template and then apply the output with `kubectl`.

To deploy our root application we need to push the files to our Git repository and apply the manifest:
```
$ git add apps
$ git ci -m 'add root app'
$ git push
$ helm template apps/ | kubectl apply -f -
```
## Let Argo CD manage itself
We previously installed Argo CD with helm install which means that updates would require us to run helm upgrade. To avoid doing this we can create an Application resource for Argo CD and let it manage itself. With this approach any updates to our Argo CD deployment can be made by modifying files in our Git repository rather than running manual commands.
We put the application manifest in apps/templates/argo-cd.yaml:
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argo-cd
  namespace: default
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  project: default
  source:
    path: charts/argo-cd
    repoURL: https://github.com/arthurk/argocd-example-install.git
    targetRevision: HEAD
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
push to `Git` repo.
```
$ git add apps/templates/argo-cd.yaml
$ git ci -m 'add argo-cd application'
$ git push
```
Once the Argo CD application is synced, we can delete it from Helm. It can now manage itself.
```
kubectl delete secret -l owner=helm,name=argo-cd
```
## How we structured our Repo
We structured our Git repo in this manner so we can manage multiple environment (.e.g dev,stg,prod) and multiple products.
```
├── apps
│   ├── Chart.yaml
│   ├── products
│   │   └── product1
│   │       ├── prometheus
│   │       │   ├── values-dev.yaml
│   │       │   └── values-prod.yaml
│   │       └── redis
│   │           ├── values-dev.yaml
│   │           └── values-prod.yaml
│   ├── templates
│   │   ├── applications.yaml
│   │   ├── argo-cd.yaml
│   │   └── root.yaml
│   ├── values-product1-dev.yaml
│   ├── values-product1-prod.yaml
│   └── values.yaml
├── charts
│   ├── argo-cd
│   │   ├── Chart.lock
│   │   ├── charts
│   │   │   └── argo-cd-2.11.0.tgz
│   │   ├── Chart.yaml
│   │   └── values.yaml
│   └── product1
│       ├── prometheus
│       │   ├── Chart.yaml
│       │   ├── templates
│       │   └── values.yaml
│       └── redis
│           ├── Chart.yaml
│           └── values.yaml
└── README.md

```
The key here is to tell Argo CD which `values` file will be used per environment. Here's how we do it.

make sure you're in the correct kubernetes `context` (e.g. `dev`)
```
$ kubectl config current-context
$ kubectl config use-context dev-env
```
Then set Argo CD
```
$ argocd app set root --values values-product-dev.yaml
```
Substitute the `values` file with the correct file for the environment, e.g. for `prod` and the product.
```
$ argocd app set root --values values-product-prod.yaml
```
 
 ## Sealed Secret

 Use [Bitnami Sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) to store secrets.

 First, encode your `secret` with base64 encryption
 ```
 $ echo -n "mySuperSecretPassword" | base64
 ```
 Then create a `secret` template. Update the name appropriately.
 ```
 ---
apiVersion: v1
kind: Secret
metadata:
  name: harbor-credential
  namespace: events
type: Opaque
data:
  token: <Your base64 Token here>
```
fetch the sealed-secret certificate.
```
$ kubeseal --fetch-cert --controller-namespace sealed-secrets --controller-name sealed-secrets > sealed-secret.crt

or you can tail the log of `sealed-secrets` controller

$ kubectl -n argocd logs <sealed-secrets-pod>
```
then, seal the secret using `kubeseal` (You should install `kubeseal`)
```
$ kubeseal < harbor-secret.yaml --cert sealed-secret.pem -o yaml > harbor-sealedsecret.yaml
```
Your `base64` password will now be `sealed`

Sample `sealed-secret.yaml`
```
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: harbor-credential
  namespace: events
spec:
  encryptedData:
    token: AgCpSyvABQxffU4wwpB7z+A7ey8nw81WmowlwkUUX+h9fYgSwJdWeAQn1+t+TesZiWg3pt6Yuy+9e+idbN100G+T7FntKwtCb8SZTiW+8NIt97GYiVCWiqXkQp1LC3uSUmqjuTW+lO2P1PCCSeh7RcVF7GEvq2Y2PgOngWT9oCaOPhtwo+kDI/5J6BTQW2OLCOh89172TRJhsqQ9WRv1f3fyXpdfr5NDJRNkWhm6iJ37sCFWn4v5WfYWouDiDQTFs9IgZgPDtb+0oFeocUl3jroeZCcbG47+HFfXnmtALgxwyu0E35lyoFgHHgu26JjAKXgrDWM+rN+ugjnR6Ee1nHPKxqFcysYcdUoaMZJjXlqY7r3BTyGryy9gnwZKS940KRKzyk9rciZoCEDQOpYiSuiEgrBGRdLt3VGKhwuBDqOZ/qth9nlIZXReQt0IEkslDMaHkOPgLo92NELMBYjfBbqpjh05L/wvjYJ1WUnRb732gg500qCr73Stb5l2rTAe0LxsWcZE/wyDV0NHdpWcwBOk1/VYcmddEQIIx8YtCuXrMTUl9Su0TKkwuSE+M/TIgBGEtxREK9eYXh1FiDP5BAyZqKQ1V2B78k/163WLn+cD/RcjEfVnIaLM5zLoxhsZ7yzbxg9FUvqvt8i/fBoRuPlAI+kYj4jbfmboSJONCgMch74WVPq7/0Oylq++vpq0Ie4KEMlLyvK+LJ7EqU+7ei9QIAgMJ68=
  template:
    metadata:
      creationTimestamp: null
      name: harbor-credential
      namespace: events
    type: Opaque
```
Then, apply using kubectl
```
$ kubectl apply -f harbor-sealedsecret.yaml
```
You'll now be able to use the secret via the name e.g. harbor-credential