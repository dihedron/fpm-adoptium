PREFIX=OpenJDK21U-jdk_x64_linux_hotspot
VERSION=21.0.1_12
NAME=adoptium-jdk21
MAINTAINER="Andrea Funtò <mailto:maintainer@example.com>"
VENDOR="ACME Inc. (vendor@example.com)"
LICENSE="BSD 3 Clause"
RELEASE=1
PRODUCER_URL=https://adoptium.net/
DOWNLOAD_URL=https://github.com/adoptium/temurin21-binaries/releases/download/jdk-$(PATH_VERSION)/$(PREFIX)_$(VERSION).tar.gz

$(PREFIX)_$(VERSION).tar.gz:
	$(eval PATH_VERSION = $(shell echo $(VERSION) | sed -e 's/_/%2B/'))
	@wget $(DOWNLOAD_URL)

.phony: prepare
prepare: $(PREFIX)_$(VERSION).tar.gz

.phony: deb
deb: prepare
	$(eval PATH_VERSION = $(shell echo $(VERSION) | sed -e 's/_/%2B/'))
	$(eval PACKAGE_VERSION = $(shell echo $(VERSION) | sed -e 's/_/\./'))
	@fpm -s tar -t deb --prefix /usr/local/adoptium --name $(NAME) --version $(PACKAGE_VERSION) --iteration $(RELEASE) \
		--description "The Adoptium.net Java Development Kit 21" \
		--vendor $(VENDOR) --maintainer $(MAINTAINER) \
		--license $(LICENSE) --directories /usr/local/adoptium/jdk-$(PATH_VERSION) \
		--url $(PRODUCER_URL) --deb-compression bzip2 \
		$(PREFIX)_$(VERSION).tar.gz

# .phony: rpm
# rpm: prepare
# 	@fpm -s tar -t rpm --prefix /usr/local --name $(NAME) --version $(VERSION) --iteration $(RELEASE) \
# 		--description "The Adoptium.net Java Development Kit 21" \
# 		--vendor $(VENDOR) --maintainer $(MAINTAINER) \
# 		--license $(LICENSE) --directories /usr/local/adoptium/jdk-$(PATH_VERSION) \
# 		--url $(PRODUCER_URL) $(PREFIX)_$(VERSION).tar.gz \
# 		--after-install _scripts/install.sh \
# 		--before-remove _scripts/uninstall.sh

.phony: clean
clean:
	$(eval PATH_VERSION = $(shell echo $(VERSION) | sed -e 's/_/\./'))
	@rm -rf $(NAME)_$(PACKAGE_VERSION)-$(RELEASE)_amd64.deb
#	@rm -rf $(NAME)_$(PACKAGE_VERSION)-$(RELEASE)_amd64.rpm

.phony: inspect
inspect:
	$(eval PACKAGE_VERSION = $(shell echo $(VERSION) | sed -e 's/_/\./'))
	@echo inspecting $(NAME)_$(PACKAGE_VERSION)-$(RELEASE)_amd64.deb
	dpkg -c $(NAME)_$(PACKAGE_VERSION)-$(RELEASE)_amd64.deb

.phony: reset
reset: clean
	@rm -rf $(PREFIX)_$(VERSION).tar.gz

.phony: help
help:
	@echo "make setup       - install FPM and other tools"
	@echo "make deb         - create a DEB package"
	@echo "make rpm         - create a RPM package"
	@echo "make clean       - remove the DEB or RPM file"
	@echo "make reset       - remove the downloaded archive"
	@echo "make install     - install the package"
	@echo "make remove      - remove the package"

# see http://linuxmafia.com/faq/Admin/release-files.html
.phony: setup
setup:
ifneq (,$(wildcard /etc/lsb-release))
	@echo "Setting up prerequisite tools for Ubuntu or Mint Linux"
	sudo apt-get update && sudo apt-get install ruby-dev build-essential && sudo gem install fpm
else ifneq (,$(wildcard /etc/debian_version)) 
	@echo "Setting up prerequisite tools for Debian Linux (TODO)"
else ifneq (,$(wildcard /etc/redhat-release)) 
	@echo "Setting up prerequisite tools for Red Hat Enterprise Linux"
	yum install -y wget ruby rpm-build && gem install fpm
else ifneq (,$(wildcard /etc/fedora-release))
	@echo "Setting up prerequisite tools for Fedora Linux (TODO)"
endif
