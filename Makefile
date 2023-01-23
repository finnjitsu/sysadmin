update:
	sudo apt update
	sudo apt upgrade
	sudo apt dist-upgrade
	sudo apt autoremove

backup-iphone:
	sudo idevicebackup2 backup -u f4547c6ca68943c344de4c7bcd561e846804c613 \
		-i -d /home/jfinn/backup/iphone

backup_files   = /home /var/mail /etc /root /boot /opt
local_dest     = /var/backups/monroe
backup_day     = $$(date +%Y-%m-%d)
backup_host    = $$(uname -n)
backup_archive = $(backup_host)-$(backup_day).tgz
remote_dest    = s3://finnjitsu-backups/monroe/

backup:

	@echo backup_files: $(backup_files)
	@echo local_dest: $(local_dest)
	@echo backup_day: $(backup_day)
	@echo backup_host: $(backup_host)
	@echo backup_archive: $(backup_archive)
	@echo remote_dest: $(remote_dest)
	@echo

	@echo "$$(date) Removing old files from $(local_dest)"
	find $(local_dest) -type f -mtime +7 -exec rm -f {} \;

	@echo "$$(date) Backing up $(backup_files) to $(local_dest)/$(backup_archive)"
	cd /
	sudo tar \
		--exclude=/home/jfinn/arc/*/repos \
		--exclude=/home/jfinn/arc/git \
		--exclude=/home/jfinn/arc/repos \
		--exclude=/home/jfinn/finnjitsu-old/repos \
		--exclude=/home/jfinn/finnjitsu \
		--exclude=/home/jfinn/.cache \
		--exclude=/home/jfinn/Downloads \
		--exclude=/home/jfinn/.local/share/Trash \
		--exclude=/home/jfinn/.config/Slack \
		--exclude=/home/jfinn/.vscode/extensions \
		--exclude=/home/jfinn/snap \
		--exclude=/home/jfinn/.mozilla \
		--exclude=/home/jfinn/vbox/machines \
		--exclude=/home/jfinn/.vagrant.d/boxes \
		--exclude=/opt/OSX-KVM \
		-czf $(local_dest)/$(backup_archive) $(backup_files)

	@echo "$$(date) Encrypting backup file $(local_dest)/$(backup_archive)"
	gpg -r jeremy.finn@gmail.com -e $(local_dest)/$(backup_archive)

	@echo "$$(date) Copying $(local_dest)/$(backup_archive) to $(remote_dest)"
	aws s3 cp $(local_dest)/$(backup_archive).gpg $(remote_dest) \
		--storage-class ONEZONE_IA --profile FINNJITSU

	@echo "$$(date) Backup finished."
	@echo "$$(date) Local space consumed:"
	ls -lh $(local_dest)
	@echo "$$(date) S3 space consumed:"
	aws s3 ls $(remote_dest) --profile FINNJITSU

set-aopen-display:
	xrandr --output DP-2 --mode 2560x1440
	xrandr --output eDP-1 --off

set-aopen-demo:
	#xrandr --output eDP-1 --auto --output DP-2 --mode 1280x1024
	xrandr --output eDP-1 --auto --output DP-2 --mode 1920x1080i
	#xrandr --output eDP-1 --auto --output DP-2 --mode 1024x768
	xrandr --output eDP-1 --off

set-acer-display:
	xrandr --output eDP-1 --auto --output DP-2-2 --mode 2560x1440
	xrandr --output eDP-1 --off

set-demo-display:
	xrandr --output eDP-1 --auto --output DP-2-2 --mode 1920x1080
	xrandr --output eDP-1 --off

set-laptop-display:
	xrandr --output eDP-1 --mode 1920x1080
	xrandr --output DP-2 --off
	xrandr --output HDMI-2 --off

set-both-displays:
	#xrandr --output eDP-1 --auto --output DP-2 --auto --left-of eDP-1
	#xrandr --output DP-2 --auto --output eDP-1 --auto --right-of DP-2
	#xrandr --output HDMI-2 --auto --output eDP-1 --auto --below HDMI-2
	#xrandr --output eDP-1 --auto --output HDMI-2 --auto --above eDP-1
	xrandr --output eDP-1 --auto --output DP-2 --auto --left-of eDP-1

set-arl-displays:
	xrandr --output DP-2-1 --auto --output eDP-1 --auto --left-of DP-2-1

set-aws-tags:
	aws ec2 create-tags --resources $(ResourceID) --tags "Key=Name,Value=$(Name)"
	aws ec2 create-tags --resources $(ResourceID) --tags "Key=Environment,Value=$(Environment)"
	aws ec2 create-tags --resources $(ResourceID) --tags "Key=CreatorOwner,Value=$(CreatorOwner)"
	aws ec2 create-tags --resources $(ResourceID) --tags "Key=CostCenter,Value=$(CostCenter)"
	aws ec2 create-tags --resources $(ResourceID) --tags "Key=Product,Value=$(Product)"
	aws ec2 create-tags --resources $(ResourceID) --tags "Key=Productcode,Value=$(ProductCode)"
	aws ec2 create-tags --resources $(ResourceID) --tags "Key=Projectcode,Value=$(ProjectCode)"
	aws ec2 create-tags --resources $(ResourceID) --tags "Key=Role,Value=$(Role)"
	aws ec2 create-tags --resources $(ResourceID) --tags "Key=Application,Value=$(Application)"
	aws ec2 create-tags --resources ${ResourceID} --tags "Key=Deployment Method,Value=$(DeploymentMethod)"
	aws ec2 create-tags --resources ${ResourceID} --tags "Key=Team,Value=$(Team)"

set-terminal-solarized-dark:
	cd ~ && rm -f .Xresources && ln -s .Xresources.solarized-dark .Xresources && xrdb ~/.Xresources

set-terminal-solarized-light:
	cd ~ && rm -f .Xresources && ln -s .Xresources.solarized-light .Xresources && xrdb ~/.Xresources

set-terminal-tango-dark:
	cd ~ && rm -f .Xresources && ln -s .Xresources.tango-dark .Xresources && xrdb ~/.Xresources

terraform:
	sudo rm -f /usr/local/bin/terraform && sudo ln -s /usr/local/bin/terraform-$(version) /usr/local/bin/terraform

backup-router:
	ssh -t root@openwrt 'sysupgrade -b /tmp/backup-`uname -n`-`date +%F`.tar.gz'
	scp root@openwrt:/tmp/backup-*.tar.gz .
	ssh root@openwrt 'rm -f /tmp/backup-*.tar.gz'
	sudo mv backup-*.tar.gz /var/backups/openwrt
	ls -lrt /var/backups/openwrt

fix-audio:
	killall pulseaudio; pulseaudio -k  ; rm -r ~/.config/pulse/* ; rm -r ~/.pulse*

bigsur:
	docker run -i \
		--device /dev/kvm \
		-p 50922:10022 \
		-p 5999:5999 \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=${DISPLAY:-:0.0}" \
		-e EXTRA="-display none -vnc 0.0.0.0:99,password=on" \
		-e GENERATE_UNIQUE=true \
		-e MASTER_PLIST_URL=https://raw.githubusercontent.com/sickcodes/osx-serial-generator/master/config-custom.plist \
		-e RAM=16 \
		-e SMP=2 \
		-e CORES=2 \
		sickcodes/docker-osx:big-sur

start-bigsur:
	(vncviewer &)
	docker start -ai 28783b1ef8f4

reload_xfce_desktop:
	killall xfconfd
	/usr/lib/x86_64-linux-gnu/xfce4/xfconf/xfconfd &
	xfsettingsd --replace &
