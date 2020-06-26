!#/bin/sh

docker run \
--name ContainerName \
--device /dev/snd \
--env HOST=192.168.1.10 \
--env SOUNDCARD=BossDAC \
saiyato/snapclient:version_tag 

# run container; connecting to snapserver at 192.168.1.10 using a BossDAC soundcard (list soundcards with: snapcast -l)
