
.PHONY: dev clean

dev:
	@wercker dev --expose-ports

clean:
	@wercker dev --pipeline clean
distclean: clean
	@rm -rf .wercker

