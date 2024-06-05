# Kubeadm Installation Guide

This guide outlines the steps needed to set up a Kubernetes cluster using kubeadm.

## Pre-requisites

* Ubuntu OS (Xenial or later)
* sudo privileges
* Internet access
* t2.medium instance type or higher
## If you reset your kubadm try below command
```bash
sudo rm -rf /var/lib/etcd
sudo kubeadm reset
sudo swapoff -a
```

## If You want to uninstall previous kubeadm
```bash
sudo kubeadm reset
sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube*   
sudo apt-get autoremove  
sudo rm -rf ~/.kube
```
## After Instalation To start service automatically during the boot, you must enable it using:
```bash
systemctl enable kubelet
```
---
## New Instalation kubeadm
## Both Master & Worker Node
**Before instalation permanently disable swapoff from both node**
```bash
sudo vi /etc/fstab
```
Delete this line:  /swap.img       none    swap    sw      0       0  

Run the following commands on both the master and worker nodes to prepare them for kubeadm.
Or Execute common.sh from the repository

```bash
sudo swapoff -a
sudo apt update

sudo modprobe overlay
sudo modprobe br_netfilter

echo "br_netfilter" | sudo tee -a /etc/modules

echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf

sudo sysctl -p

sudo apt update
sudo apt -y upgrade

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
apt-cache policy docker-ce
sudo apt install -y docker-ce

sudo systemctl start docker
sudo systemctl enable docker 
sudo usermod -aG docker ${USER}

sudo rm /etc/containerd/config.toml
sudo systemctl restart docker 
sudo systemctl restart containerd

# install kubeadm


sudo mkdir /etc/apt/keyrings/

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

sudo apt install -y kubelet kubeadm kubectl kubernetes-cni

```



---

## Prerequisit for master node
Turn off ufw or allow this ports: 6443/tcp, 2379–2380/tcp, 10250/tcp, 10251/tcp, 10252/tcp 10255/tcp

## Master Node
After initialization of master run this command if gets an error like  **[ERROR CRI]: container runtime is not running**

```bash
sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd
```

1. Initialize the Kubernetes master node.
   or execute master.sh from the repository

    ```bash
    sudo kubeadm init
    ```

    After succesfully running, your Kubernetes control plane will be initialized successfully.

   <kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/760276f4-9146-4bc1-aa92-48cc1c0b13f4)</kbd>


3. Set up local kubeconfig (both for root user and normal user):

    ```bash
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    ```

4. Apply Weave network:

    ```bash
    kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
    ```

    <kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/ec7b4684-7719-4d09-81d8-eee27b98972a)</kbd>


5. Generate a token for worker nodes to join:

    ```bash
    sudo kubeadm token create --print-join-command
    ```

    <kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/0370839b-bbac-415c-9d5a-9ab52cd3108b)</kbd>

6. Expose port 6443 in the Security group for the Worker to connect to Master Node

<kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/b3f5df01-acb0-419f-aa70-6d51819f4ec0)</kbd>


---

## Worker Node

1. Run the following commands on the worker node.

    ```bash
    sudo kubeadm reset pre-flight checks
    ```

2. Paste the join command you got from the master node and append `--v=5` at the end.
*Make sure either you are working as sudo user or use `sudo` before the command*

   <kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/c41e3213-7474-43f9-9a7b-a75694be582a)</kbd>

   After succesful join->
   <kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/c530b65a-4afd-4b1d-9748-421c216d64cd)</kbd>

---

## Verify Cluster Connection

On Master Node:

```bash
kubectl get nodes
```
<kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/4ed4dcac-502a-4cc1-a63e-c9cbb0199428)</kbd>

---

## Optional: Labeling Nodes

If you want to label worker nodes, you can use the following command:

```bash
kubectl label node <node-name> node-role.kubernetes.io/worker=worker
```

---

## Optional: Test a demo Pod 

If you want to test a demo pod, you can use the following command:

```bash
kubectl run hello-world-pod --image=busybox --restart=Never --command -- sh -c "echo 'Hello, World' && sleep 3600"
```

<kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/bace1884-bbba-4e2f-8fb2-83bbba819d08)</kbd>
