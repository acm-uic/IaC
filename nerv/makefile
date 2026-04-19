latest: Containerfile usr etc
	ssh root@bootc-builder.acmuic.org "rm -rf bootc/nerv/"
	rsync -avzhP --exclude="*.iso" $(PWD)/ root@bootc-builder.acmuic.org:bootc/nerv/
	ssh root@bootc-builder.acmuic.org "cd bootc/nerv/ && ./gen.sh $(@)"
	pssh -i -t 0 -p 4 -h nerv.ssh "bootc upgrade && reboot"

.DEFAULT_GOAL := latest

all: both



