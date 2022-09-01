# Azure Load Balancer

## Azure Standard LB, Azure NAT GW and Cost

~~~ bash
prefix=cptdazlb
location=eastus
az group create -n $prefix -l $location
~~~

## Misc

### github
~~~ bash
gh repo create $prefix --private
git init
git remote add origin https://github.com/cpinotossi/$prefix.git
git submodule add https://github.com/cpinotossi/azbicep
git submodule init
git submodule update
git submodule update --init
git status
git add .gitignore
git add *
git commit -m"init"
git push origin main
git push --recurse-submodules=on-demand
git rm README.md # unstage
git --help
git config advice.addIgnoredFile false
~~~