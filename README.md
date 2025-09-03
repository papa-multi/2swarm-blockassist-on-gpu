



How to run two Swarm nodes on a single GPU,
and also run a Block Assist node on the same GPU server.

--------------------------------

# NODE 1  just use gpu 


# 1) Install Dependencies :

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

---



---

## 2) Clone the Repository :
```
git clone https://github.com/gensyn-ai/rl-swarm/
```

```
cp -r rl-swarm rl-swarm2
```
note:
now you have 2 swarm first run on just gpu 

> `NB`: By *GPU only*, it means:
> * **VRAM** is used extensively
> *  **RAM** is used minimally
> *  **CPU** usage is limited to a single core


```
cd rl-swarm
```

first go to change 

```
nano /root/rl-swarm/rgym_exp/config/rg-swarm.yaml
```

* `num_train_samples: 1`
* `num_transplant_trees: 1`
* `beam_size: 40`

# 3) run swarm :

```
screen -S swarm1
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


# important note: 

If your GPU VRAM is less than **24 GB**, you should choose one of the following models:

* **Gensyn/Qwen2.5-0.5B-Instruct**
* **Qwen/Qwen3-0.6B**

-----------------------------------------------

# NODE 2 just use cpu and ram 

```
cd rl-swarm2
```

# 1) change port



note :  Replace every occurrence of 3000 in the file with 3001.   If you want to verify, press `Ctrl + W` , type 3000, and hit Enter.

```
nano /root/rl-swarm/rgym_exp/config/rg-swarm.yaml
```

note :  Replace every occurrence of 3000 in the file with 3001.   If you want to verify, press `Ctrl + W` , type 3000, and hit Enter.  and `CPU_ONLY=${CPU_ONLY:-"true"}`

```
nano run_rl_swarm.sh
```


-------------
Change 3000 to 3001 
for package.json 
Make it like this 

```
nano modal-login/package.json
```

```
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
```

ctrl + x +y  enter 


# now change this 

```
nano /root/rl-swarm/rgym_exp/config/rg-swarm.yaml
```

* `num_train_samples: 2` (If your node freezes without any errors, then change it to 1. Otherwise, leave it as 2.)
* `num_transplant_trees: 1`
* `beam_size: 30`

----------
# 2) run swarm 2 



Make sure you are in this directory: `rl-swarm2`

```
cd rl-swarm2
```

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

# important note: 

* **Gensyn/Qwen2.5-0.5B-Instruct**
* **Qwen/Qwen3-0.6B**

If you used either of these in **Node 1**, use a different one here.


<img width="1920" height="962" alt="gensyn 2node" src="https://github.com/user-attachments/assets/3182455a-68d5-4dd1-b4c8-7a97a588bfa4" />


# important note

At the top right: **CPU only**
At the bottom right: **GPU only**

As you can see, there’s still available RAM.

Using the same method and by changing the port, you can run another swarm node on **CPU only**.



-------------------

# block assist 



To run Block Assist, you can use this repository

 install sunshine [guide](https://github.com/papa-multi/sunshine-script)


 install blockassist [guide](https://github.com/papa-multi/gensyn-blockassist)

You just need to change the ports to 3002 if you want to run it on the same server where you already have two Swarm nodes running.


Change 3000 to 3002 

```nano modal_server.sh```


```nano src/blockassist/blockchain/coordinator.py```



and for package.json 
Make it like this 

```nano modal-login/package.json```


```{
  "name": "ui-components-qs-nextjs",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "next dev -p 3002",
    "build": "next build",
    "start": "next start -p 3002",
    "lint": "next lint"
  },
```












