REGION=ap-southeast-1
P7ZIP_VERSION="16.02"
P7ZIP_DOWNLOAD_URL="https://sourceforge.net/projects/p7zip/files/p7zip/${P7ZIP_VERSION}/p7zip_${P7ZIP_VERSION}_src_all.tar.bz2/download"

build: build/layer.zip

build/bin/7za: 
	mkdir -p build/bin
	rm -rf build/p7zip*
	cd build; \
		curl -L ${P7ZIP_DOWNLOAD_URL} | tar xj
	cd build/p7zip*; \
		cp makefile.linux_any_cpu_gcc_4.X makefile.machine; \
		docker run --rm -v "$${PWD}":/var/task lambci/lambda:build-nodejs8.10 make
	mv build/p7zip*/bin/7za build/bin

build/layer.zip: build/bin/7za
	cd build && zip -r layer.zip bin

publish: build/layer.zip
	aws lambda publish-layer-version \
		--layer-name p7zip \
		--zip-file fileb://build/layer.zip \
		--description "p7zip file archiver binary" \
		--license-info "LGPL-2.1-or-later" \
		--compatible-runtimes nodejs8.10 java8 python3.6 ruby2.5 go1.x \
		--region ${REGION} \
		--output text

clean: 
	rm -rf build
