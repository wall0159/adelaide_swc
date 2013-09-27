#!/bin/bash
sudo apt-get update && sudo apt-get -y dist-upgrade

urls=(
  'https://github.com/pypa/pip.git'
  'git://github.com/openstack-dev/pbr.git'
  'git://github.com/iguananaut/d2to1.git'
  'https://github.com/kelp404/six.git'
  'https://github.com/openstack/python-glanceclient.git'
  'https://github.com/openstack/python-keystoneclient.git'
  'https://github.com/openstack/python-novaclient.git'
  'https://github.com/openstack/python-swiftclient.git'
)

for url in ${urls[@]}; do
  output_dir=${url##*/}
  output_dir=${output_dir%%.git}
  if [[ ! -e ./${output_dir} ]]; then
    git clone $url ./${output_dir}
    cd ./${output_dir}
  else
    cd ./${output_dir}
    git pull
  fi
  
  sudo python setup.py install
  cd ../
done
