# ConvolutedDKBG
Docker AWS Method To Update Desktop Background Image

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

or install docker on one of our monitoring Nagios servers...

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

service docker start
cd /docker
mkdir curl
cd curl
vi Dockerfile   (https://github.com/uzyexe/dockerfile-curl)
docker build . 
docker build -t joe/curl .

mkdir -p /home/jrogers/dkbg/
docker run joe/curl https://apod.nasa.gov/apod/astropix.html  2> /dev/null | grep IMG |sed -r 's/<IMG SRC="(.*)"/docker run -v \/home\/jrogers\/dkbg:\/home  joe\/curl -o /home/dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/' > /home/jrogers/dkbg/url


[root@esv-centos7-joe01 docker]# docker run -v /home/jrogers/dkbg:/home  joe/curl -o /home/dkbg.jpg https://apod.nasa.gov/apod/image/1706/BHmassChartGW17p1024.jpg
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  253k  100  253k    0     0   126k      0  0:00:02  0:00:02 --:--:--  126k
[root@esv-centos7-joe01 docker]# ls -l /home/jrogers/dkbg/
total 256
-rw-r--r--. 1 root root 259391 Jun  2 19:01 dkbg.jpg


eval $(docker run joe/curl https://apod.nasa.gov/apod/astropix.html  2> /dev/null | grep IMG |sed -r 's/<IMG SRC="(.*)"/docker run -v \/home\/jrogers\/dkbg:\/home  joe\/curl -o \/home\/dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/')

Now from within Alpine, installing curl inside the get image script:
docker  run -it --rm -v /home/jrogers/dkbg:/home alpine /bin/ash
apk --no-cache add curl
/bin/ash /home/getnasaIOD.sh

One Line:
docker  run -v /home/jrogers/dkbg:/home alpine /bin/ash /home/getnasaIOD.sh

# cat /home/jrogers/dkbg/getnasaIOD.sh
#!/bin/ash
apk --no-cache add curl
curl https://apod.nasa.gov/apod/astropix.html 2> /dev/null  | grep IMG |sed -r 's/<IMG SRC="(.*)"/curl -o \/home\/dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/'  | /bin/ash


Or build curl into alpine:
# cat /docker/alpine.curl/Dockerfile
FROM alpine
RUN apk update && apk upgrade
RUN apk --no-cache add curl

# cat getnasaIOD.sh
#!/bin/ash
curl https://apod.nasa.gov/apod/astropix.html 2> /dev/null  | grep IMG |sed -r 's/<IMG SRC="(.*)"/curl -o \/home\/dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/'  | /bin/ash

docker  run -it --rm -v /home/jrogers/dkbg:/home alpine.curl /bin/ash

One line:
docker run -v /home/jrogers/dkbg:/home alpine.curl /bin/ash /home/getnasaIOD.sh

Host image on web server:



Host image behind nginx load balancer:



Overlay image with AWS location it is being hosted on:


Store image file on a database:


Store Host image in pieces, with high availability, kill one piece and recover or continue to host from parity:

