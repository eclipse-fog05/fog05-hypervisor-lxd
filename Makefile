# -*-Makefile-*-

WD := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))));
UUID = $(shell ./to_uuid.sh)

ETC_FOS_DIR = /etc/fos/
VAR_FOS_DIR = /var/fos/
FOS_CONF_FILE = /etc/fos/agent.json
LXD_PLUGIN_DIR = /etc/fos/plugins/plugin-fdu-lxd
LXD_PLUGIN_CONFFILE = $(LXD_PLUGIN_DIR)/LXD_plugin.json
SYSTEMD_DIR = /lib/systemd/system/

clean:
	echo "Nothing to do"

all:
	echo "Nothing to do..."

install:
	# sudo pip3 install pylxd jinja2 packaging
	# sudo usermod -aG lxd fos
ifeq "$(wildcard $(LXD_PLUGIN_DIR))" ""
	mkdir -p $(LXD_PLUGIN_DIR)
	sudo cp -r ./templates $(LXD_PLUGIN_DIR)
	sudo cp ./__init__.py $(LXD_PLUGIN_DIR)
	sudo cp ./LXD_plugin $(LXD_PLUGIN_DIR)
	sudo cp ./LXDFDU.py $(LXD_PLUGIN_DIR)
	sudo cp ./README.md $(LXD_PLUGIN_DIR)
	sudo cp ./LXD_plugin.json  $(LXD_PLUGIN_DIR)
else
	sudo cp -r ./templates $(LXD_PLUGIN_DIR)
	sudo cp ./__init__.py $(LXD_PLUGIN_DIR)
	sudo cp ./LXD_plugin $(LXD_PLUGIN_DIR)
	sudo cp ./LXDFDU.py $(LXD_PLUGIN_DIR)
	sudo cp ./README.md $(LXD_PLUGIN_DIR)
endif
	sudo cp ./fos_lxd.service $(SYSTEMD_DIR)
	sudo sh -c "echo $(UUID) | xargs -i  jq  '.configuration.nodeid = \"{}\"' $(LXD_PLUGIN_CONFFILE) > /tmp/LXD_plugin.tmp && mv /tmp/LXD_plugin.tmp $(LXD_PLUGIN_CONFFILE)"


uninstall:
	sudo systemctl disable fos_lxd
	gpasswd -d fos lxd
	sudo rm -rf $(LXD_PLUGIN_DIR)
	sudo rm -rf $(VAR_FOS_DIR)/lxd
	sudo rm $(SYSTEMD_DIR)/fos_lxd.service
