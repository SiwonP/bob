install:
	@echo "Installing bob"
	cp bob /usr/local/bin
	cp bob2 /usr/local/bin
	cp -r lib /usr/local/lib/bob

uninstall:
	@echo "Uninstalling bob"
	rm /usr/local/bin/bob
	rm /usr/local/bin/bob2
	rm -r /usr/local/lib/bob


test:
	/bin/sh ./test/test.sh