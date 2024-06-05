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

sudo apt-get install -y wget gnupg-agent software-properties-common
sudo apt-get update -y
sudo apt install -y containerd.io
sudo rm /etc/containerd/config.toml

sudo systemctl daemon-reload
sudo systemctl restart containerd

# install kubeadm


sudo mkdir /etc/apt/keyrings/

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

sudo apt install -y kubelet kubeadm kubectl kubernetes-cni
