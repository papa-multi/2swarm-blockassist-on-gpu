


> `NB`: By *GPU only*, it means:
> * **VRAM** is used extensively
> *  **RAM** is used minimally
> *  **CPU** usage is limited to a single core

How to run two Swarm nodes on a single GPU,
and also run a Block Assist node on the same GPU server.

--------------------------------


# 1- Install Dependencies :

```
 sudo apt update && sudo apt upgrade -y
```

```
sudo apt install screen curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y
```

```
sudo apt install python3 python3-pip python3-venv python3-dev -y
```
```
sudo apt update
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt install -y nodejs
node -v
npm install -g yarn
yarn -v
```


```
curl -o- -L https://yarnpkg.com/install.sh | bash
```

```
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
```

```
source ~/.bashrc
```

## install docker :

install Go

```console
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.22.3.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source .bash_profile
go version
```


 Docker, Docker-Compose

```console
sudo apt update -y && sudo apt upgrade -y
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y && sudo apt upgrade -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Test Docker
sudo docker run hello-world
```

see your docker :

```
docker ps -a
```

--------------

## 2- Clone the Repository :
```
git clone https://github.com/gensyn-ai/rl-swarm/
```

```
cp -r rl-swarm rl-swarm2
```



# 3- run first swarm-node :

```
cd rl-swarm & screen -S swarm1
```

```
python3 -m venv .venv

source .venv/bin/activate
# if not worked, then:
. .venv/bin/activate

```

```
./run_rl_swarm.sh
```

## Login :

**1- You have to receive `Waiting for userData.json to be created...` in logs**

Note: Open a new terminal


**2- Open login page in browser**
* **Local PC:** Open `http://localhost:3000/` in your browser
* **GPU Cloud & VPS Users: Tunnel to external URL:**
  * 1- Open a new terminal
  * 2- Install **localtunnel**:
    ```
    sudo npm install -g localtunnel
    ```
  * 3- Get a password:
    ```
    curl https://loca.lt/mytunnelpassword
    ```
  * The password is actually your VPS IP
  * 4- Get URL
    ```
    lt --port 3000
    ```
  * Visit the prompted url, and enter your password to access Gensyn login page
    


-----------------------------------------------



```
cd rl-swarm2
```

# 1) change port 

`3000 to 30001`

```
sed -i 's/3000/3001/g' run_rl_swarm.sh
```

```
sed -i 's/"dev": "next dev"/"dev": "next dev -p 3001"/; s/"start": "next start"/"start": "next start -p 3001"/' modal-login/package.json
```

modal-login/package.json change to this :

`
{
  "name": "ui-components-qs-nextjs",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "next dev -p 3001",
    "build": "next build",
    "start": "next start -p 3001",
    "lint": "next lint"
  },
`

check

```
cat modal-login/package.json
```

# run seconde swarm-node

  Make sure you are in this directory: `rl-swarm2`
```
screen -S SWARM2
```

```
python3 -m venv .venv

source .venv/bin/activate
# if not worked, then:
. .venv/bin/activate

```

```
CUDA_VISIBLE_DEVICES="-1" ./run_rl_swarm.sh
```

## Login :

**1- You have to receive `Waiting for userData.json to be created...` in logs**

Note: Open a new terminal


**2- Open login page in browser**
* **Local PC:** Open `http://localhost:3001/` in your browser
* **GPU Cloud & VPS Users: Tunnel to external URL:**
  * 1- Open a new terminal
  * 2- Install **localtunnel**:
    ```
    sudo npm install -g localtunnel
    ```
  * 3- Get a password:
    ```
    curl https://loca.lt/mytunnelpassword
    ```
  * The password is actually your VPS IP
  * 4- Get URL
    ```
    lt --port 3001
    ```
  * Visit the prompted url, and enter your password to access Gensyn login page



<img width="1920" height="962" alt="gensyn 2node" src="https://github.com/user-attachments/assets/3182455a-68d5-4dd1-b4c8-7a97a588bfa4" />

At the top right: **CPU only**
At the bottom right: **GPU only**

As you can see, there’s still available RAM.






