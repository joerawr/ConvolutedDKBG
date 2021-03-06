ConvolutedDKBG
Docker AWS Method To Update Ubuntu Desktop Background Image

Project:
Download Nasa's Astronomy image of the day and reset the background image on my Ubuntu Desktop, in an extremely convoluted, but cost efficient, method using Docker and AWS.

Image Source
https://apod.nasa.gov/apod/astropix.html
or
https://apod.nasa.gov/apod/archivepix.html

Image Magik text overlay
http://www.imagemagick.org/Usage/annotating/#anno_on

Ubuntu
Assuming you're using standard Ubuntu 16.04 with Unity, you can use the following command to set the wallpaper:

gsettings set org.gnome.desktop.background picture-uri "file:///home/username/path/to/image.jpg"


You can get the current URI of the background image as follows:

gsettings get org.gnome.desktop.background picture-uri
'file:///home/serrano/Pictures/x.jpg'
And set the background URI as follows (which will immediately update your desktop background):

gsettings set org.gnome.desktop.background picture-uri file:///home/serrano/Pictures/y.jpg


Commands to get capture the image URL:
curl https://apod.nasa.gov/apod/astropix.html | grep jpg
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4338    0  4338    0     0   7268      0<a href="image/1706/BHmassChartGW17.jpg">
 --:-<IMG SRC="image/1706/BHmassChartGW17p1024.jpg"


wget https://apod.nasa.gov/apod/image/1706/BHmassChartGW17p1024.jpg


Spin up VM

spin up container
# Copy current background to backup file

cp dkbg.jpg dkbg.jpg.`date +%m%d 

# Using Bash, curl and wget:
curl https://apod.nasa.gov/apod/astropix.html 2> /dev/null | grep IMG |sed -r 's/<IMG SRC="(.*)"/wget -q -O dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/'  |/bin/bash

# Using Eval, curl and wget:
eval $(curl https://apod.nasa.gov/apod/astropix.html 2> /dev/null | grep IMG |sed -r 's/<IMG SRC="(.*)"/wget -q -O dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/' )

# Using Eval, curl
eval $(curl https://apod.nasa.gov/apod/astropix.html 2> /dev/null | grep IMG |sed -r 's/<IMG SRC="(.*)"/curl -o dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/' )

# Just curl:
curl https://apod.nasa.gov/apod/astropix.html 2> /dev/null | grep IMG |sed -r 's/<IMG SRC="(.*)"/curl -o dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/'

eval $(curl https://apod.nasa.gov/apod/astropix.html 2> /dev/null | grep IMG |sed -r 's/<IMG SRC="(.*)"/curl -o dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/' ) ; gsettings set org.gnome.desktop.background picture-uri "file:////home/jrogers/dkbg.jpg"

su -c "setenforce 0"  # Required for CentOS
mkdir -p /docker/ConvolutedDKBG
service docker start
cd /docker/ConvolutedDKBG
mkdir alpine
cd alpine
sudo docker pull alpine
sudo docker  run -it --rm -v /docker/ConvolutedDKBG/vol1:/home alpine /bin/ash

Now from within Alpine, installing curl inside the get image script:
sudo docker  run -it --rm -v /docker/ConvolutedDKBG/vol1/:/home alpine /bin/ash
apk --no-cache add curl
/bin/ash /home/getnasaIOD.sh

One Line:
sudo docker  run -v /docker/ConvolutedDKBG/vol1/:/home alpine /bin/ash /home/getnasaIOD.sh

# cat /docker/ConvolutedDKBG/vol1/getnasaIOD.sh
#!/bin/ash
apk --no-cache add curl
curl https://apod.nasa.gov/apod/astropix.html 2> /dev/null  | grep IMG |sed -r 's/<IMG SRC="(.*)"/curl -o \/home\/dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/'  | /bin/ash


Or build curl into alpine:
mkdir alpine.curl
cd alpine.curl/
vi Dockerfile
# cat /docker/ConvolutedDKBG/alpine.curl/Dockerfile
FROM alpine
RUN apk update && apk upgrade
RUN apk --no-cache add curl

sudo docker build .
sudo docker build -t alpine.curl .

# cat getnasaIOD.sh
#!/bin/ash
curl https://apod.nasa.gov/apod/astropix.html 2> /dev/null  | grep IMG |sed -r 's/<IMG SRC="(.*)"/curl -o \/home\/dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/'  | /bin/ash

sudo docker  run -it --rm -v /docker/ConvolutedDKBG/vol1/:/home alpine.curl /bin/ash

One line:
sudo docker run -v /docker/ConvolutedDKBG/vol1/:/home alpine.curl /bin/ash /home/getnasaIOD.sh

Host image on web server:
mkdir /docker/ConvolutedDKBG/vol1/html/images
mkdir -p /docker/ConvolutedDKBG/vol1/nginxconf
sudo docker run -it --rm --name mynginx -v /docker/ConvolutedDKBG/nginx/conf:/tmp  -P nginx /bin/bash
  inside nginx: cp -r /etc/nginx /tmp 

sudo docker run -it --rm --name mynginx -v /docker/ConvolutedDKBG/nginx/content:/tmp  -P nginx /bin/bash
  inside nginx: cp -r /usr/share/nginx/html /tmp


# need more files for /etc/nginx, better to create Dockerfile
sudo docker run --name mynginx -v /docker/ConvolutedDKBG/vol1/html/:/usr/share/nginx/html:ro -v /docker/ConvolutedDKBG/vol1/nginxconf:/etc/nginx:ro -P -d nginx

So use this for now:
sudo docker run --name mynginx -v /docker/ConvolutedDKBG/vol1/html/images:/usr/share/nginx/html/images:ro -P -d nginx
sudo docker stop mynginx
sudo docker rm mynginx

# Docker Compose
# Clean up previous run, destroying the images and the share
sudo docker-compose -f docker-compose_haproxy.yml down --rmi all; sudo docker volume rm convoluteddkbg_shared-vol

# Bring it up
sudo docker-compose -f docker-compose_haproxy.yml up --build -d

# Scale it
sudo docker-compose -f docker-compose_haproxy.yml scale nginx=5

# cheap way of identifying the container IDs
for i in {1..5}
do sudo docker exec -it convoluteddkbg_nginx_$i sed -i "s/CONTNAME/nginx$i/" /usr/share/nginx/html/index.html
done


Store image file on a database:

Store Host image in pieces, with high availability, kill one piece and recover or continue to host from parity:

Host image behind load balancer:

Overlay image with AWS location it is being hosted on:
