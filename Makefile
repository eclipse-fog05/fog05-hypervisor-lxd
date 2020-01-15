# -*-Makefile-*-

WD := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))));
UUID = $(shell ./to_uuid.sh)

ETC_FOS_DIR = /etc/fos/
VAR_FOS_DIR = /var/fos/
FOS_CONF_FILE = /etc/fos/agent.json
LXD_PLUGIN_DIR = /etc/fos/plugins/plugin-fdu-lxd
LLXD_PLUGIN_CONFFILE = /etc/fos/plugins/plugin-fdu-lxd/LXD_plugin.json
all:
	echo "Nothing to do..."

install:
	sudo pip3 install pylxd jinja2 packaging
	sudo usermod -aG lxd fos
ifeq "$(wildcard $(LXD_PLUGIN_DIR))" ""
	sudo cp -r ../plugin-fdu-lxd /etc/fos/plugins/
else
	sudo cp -r ../plugin-fdu-lxd/templates /etc/fos/plugins/plugin-fdu-lxd/
	sudo cp ../plugin-fdu-lxd/__init__.py /etc/fos/plugins/plugin-fdu-lxd/
	sudo cp ../plugin-fdu-lxd/LXD_plugin /etc/fos/plugins/plugin-fdu-lxd/
	# sudo cp ../LXD/LXD_plugin.json /etc/fos/plugins/LXD/
	sudo cp ../plugin-fdu-lxd/LXDFDU.py /etc/fos/plugins/plugin-fdu-lxd/
	sudo cp ../plugin-fdu-lxd/README.md /etc/fos/plugins/plugin-fdu-lxd/
	sudo ln -sf /etc/fos/plugins/plugin-fdu-lxd/LXD_plugin /usr/bin/fos_lxd
endif
	sudo cp /etc/fos/plugins/plugin-fdu-lxd/fos_lxd.service /lib/systemd/system/
	sudo sh -c "echo $(UUID) | xargs -i  jq  '.configuration.nodeid = \"{}\"' /etc/fos/plugins/plugin-fdu-lxd/LXD_plugin.json > /tmp/LXD_plugin.tmp && mv /tmp/LXD_plugin.tmp /etc/fos/plugins/plugin-fdu-lxd/LXD_plugin.json"


uninstall:
	sudo systemctl disable fos_lxd
	gpasswd -d fos lxd
	sudo rm -rf /etc/fos/plugins/plugin-fdu-lxd
	sudo rm -rf /var/fos/lxd
	sudo rm /lib/systemd/system/fos_lxd.service
	sudo rm -rf /usr/bin/fos_lxd
