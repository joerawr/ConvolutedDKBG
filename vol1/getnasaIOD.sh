#!/bin/ash
curl https://apod.nasa.gov/apod/astropix.html 2> /dev/null  | grep IMG |sed -r 's/<IMG SRC="(.*)"/curl -o \/home\/html\/images\/dkbg.jpg https:\/\/apod.nasa.gov\/apod\/\1/'  | /bin/ash
