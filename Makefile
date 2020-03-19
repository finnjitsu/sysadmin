update-laptop:
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

backup-laptop:

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
		--exclude=/home/jfinn/arc/repos \
		--exclude=/home/jfinn/finnjitsu/repos \
		-czf $(local_dest)/$(backup_archive) $(backup_files)

	@echo "$$(date) Encrypting backup file $(local_dest)/$(backup_archive)"
	gpg -r jeremy.finn@gmail.com -e $(local_dest)/$(backup_archive)

	@echo "$$(date) Copying $(local_dest)/$(backup_archive) to $(remote_dest)"
	aws s3 cp $(local_dest)/$(backup_archive).gpg $(remote_dest) \
		--storage-class ONEZONE_IA --profile FINNJITSU

	@echo "$$(date) Backup finished. Local space consumed:"
	ls -lh $(local_dest)

set-aopen-display:
	xrandr --output eDP-1 --auto --output DP-2 --mode 2560x1440
	xrandr --output eDP-1 --off

set-acer-display:
	xrandr --output eDP-1 --auto --output DP-2-2 --mode 2560x1440
	xrandr --output eDP-1 --off

set-demo-display:
	xrandr --output eDP-1 --auto --output DP-2-2 --mode 1920x1080
	xrandr --output eDP-1 --off

set-laptop-display:
	xrandr --output eDP-1 --auto --output DP-2-2 --mode 1920x1080
	xrandr --output DP-2-2 --off

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

set-terminal-dark:
	cd ~ && rm -f .Xresources && ln -s .Xresources.dark .Xresources && xrdb ~/.Xresources

set-terminal-light:
	cd ~ && rm -f .Xresources && ln -s .Xresources.light .Xresources && xrdb ~/.Xresources
