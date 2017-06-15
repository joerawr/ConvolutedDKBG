FROM alpine
RUN apk update && apk upgrade
RUN apk --no-cache add curl
VOLUME shared_vol:/shared
COPY getnasaIOD.sh /shared/ 
RUN /bin/ash /shared/getnasaIOD.sh
