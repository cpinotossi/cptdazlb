# Azure Load Balancer

## Azure Standard LB, Azure NAT GW and Outbound traffic

Overview:
~~~ mermaid
classDiagram
StandardLB1 --> spoke1
hub --> spoke1 : peering
hub --> spoke2 : peering
NATGW --> spoke2: assigned
StandardLB2 --> spoke2
NATGW: pubip
StandardLB1: pubip
StandardLB2: pubip
hub : cidr 10.0.0.0/16
hub : bastion
spoke2 : cidr 10.2.0.0/16
spoke2 : vm 10.2.0.4
spoke1 : cidr 10.1.0.0/16
spoke1 : vm 10.1.0.4
~~~

~~~ bash
prefix=cptdazlb
location=eastus
myip=$(curl ifconfig.io) # Just in case we like to whitelist our own ip.
myobjectid=$(az ad user list --query '[?displayName==`ga`].id' -o tsv) # just in case we like to assing



az group delete -n $prefix --yes
az group create -n $prefix -l $location
az deployment group create -n $prefix -g $prefix --mode incremental --template-file deploy.bicep -p prefix=$prefix myobjectid=$myobjectid location=$location myip=$myip

az network nic ip-config address-pool add --address-pool ${prefix}spoke1 --ip-config-name ${prefix}spoke1 --nic-name ${prefix}spoke1 -g $prefix --lb-name ${prefix}spoke1
az network lb outbound-rule update -g $prefix --lb-name ${prefix}spoke1 --name ${prefix}spoke1 --address-pool ${prefix}spoke1

az network nic ip-config address-pool add --address-pool ${prefix}spoke2 --ip-config-name ${prefix}spoke2 --nic-name ${prefix}spoke2 -g $prefix --lb-name ${prefix}spoke2
az network lb outbound-rule update -g $prefix --lb-name ${prefix}spoke2 --name ${prefix}spoke2 --address-pool ${prefix}spoke2
~~~

Connect to spoke1 vm:

~~~ bash
ls -la azbicep/ssh/chpinoto.key # should be -rwxrwxrwx
sudo chmod 600 azbicep/ssh/chpinoto.key
ls -la azbicep/ssh/chpinoto.key # should be -rw------- now
spoke1vmid=$(az vm show -g $prefix -n ${prefix}spoke1 --query id -o tsv)
az network bastion ssh -n ${prefix}hub -g $prefix --target-resource-id $spoke1vmid --auth-type ssh-key --username chpinoto --ssh-key azbicep/ssh/chpinoto.key
demo!pass123
curl http://ifconfig.io # pub ip of Standard LB 1, 52.224.138.18
logout
az network public-ip list -g $prefix -o table --query "[?name=='${prefix}spoke1'].{name:name,ipAddress:ipAddress}"
~~~

Connect to spoke2 vm:

~~~ bash
ls -la azbicep/ssh/chpinoto.key # should be -rwxrwxrwx
sudo chmod 600 azbicep/ssh/chpinoto.key
ls -la azbicep/ssh/chpinoto.key # should be -rw------- now
spoke2vmid=$(az vm show -g $prefix -n ${prefix}spoke2 --query id -o tsv)
az network bastion ssh -n ${prefix}hub -g $prefix --target-resource-id $spoke2vmid --auth-type ssh-key --username chpinoto --ssh-key azbicep/ssh/chpinoto.key
demo!pass123
curl http://ifconfig.io # pub ip of your NAT Gateway
logout
az network public-ip list -g $prefix -o table --query "[?name=='${prefix}spoke2'].{name:name,ipAddress:ipAddress}"
~~~

Clean up:
~~~ bash
az group delete -n $prefix --yes
~~~

## Misc

### github
~~~ bash
gh repo create $prefix --public
git init
git remote add origin https://github.com/cpinotossi/$prefix.git
git submodule add https://github.com/cpinotossi/azbicep
git submodule init
git submodule update
git submodule update --init
git status
git add .gitignore
git add *
git commit -m"Partly working"
git push origin main
git push --set-upstream origin main
git push --recurse-submodules=on-demand
git rm README.md # unstage
git --help
git config advice.addIgnoredFile false
~~~