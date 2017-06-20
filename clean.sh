sudo docker rmi $(sudo docker images | grep convoluted | awk '{print $3}')
