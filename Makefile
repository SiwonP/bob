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

.PHONY: test  # Declare 'test' as a phony target

test:
	bash ./test/test.sh