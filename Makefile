default: all

REGISTRY=nexus.daf.teamdigitale.it


.PHONY: activemq
activemq:
	docker build -t tba-activemq -f docker/activemq/Dockerfile docker/activemq
	docker tag tba-activemq $(REGISTRY)/tba-activemq.5.15.1:1.1.0
	docker push $(REGISTRY)/tba-activemq.5.15.1:1.1.0

.PHONY: mysql
mysql:
	mkdir -p docker/mysql/dist
	cp -R ../kylok8s/install/install-tar/target/kylo/setup/sql/mysql/kylo/* docker/mysql/dist
	docker build -t tba-mysql -f docker/mysql/Dockerfile docker/mysql
	docker tag tba-mysql $(REGISTRY)/tba-mysql.10.3:1.1.0
	docker push $(REGISTRY)/tba-mysql.10.3:1.1.0
	rm -dr docker/mysql/dist

.PHONY: kylo-services
kylo-services:
		mkdir -p docker/kylo-services/dist/kylo-services && \
		if [ ! -f ../kylok8s/install/install-tar/target/kylo/kylo-services/lib/postgresql-42.1.4.jar ] ;then curl -o ../kylok8s/install/install-tar/target/kylo/kylo-services/lib/postgresql-42.1.4.jar http://central.maven.org/maven2/org/postgresql/postgresql/42.1.4/postgresql-42.1.4.jar  ;fi
		cp -R ../kylok8s/install/install-tar/target/kylo/kylo-services/lib docker/kylo-services/dist/kylo-services
		cp -R ../kylok8s/install/install-tar/target/kylo/kylo-services/plugin docker/kylo-services/dist/kylo-services
		cp -R ../kylok8s/install/install-tar/target/kylo/bin docker/kylo-services/dist
		cp -R ../kylok8s/install/install-tar/target/kylo/lib docker/kylo-services/dist
		docker build -t tba-kylo-services -f docker/kylo-services/Dockerfile docker/kylo-services
		docker tag tba-kylo-services $(REGISTRY)/tba-kylo-services.8.4:1.1.0
		docker push $(REGISTRY)/tba-kylo-services.8.4:1.1.0
		rm -dr docker/kylo-services/dist

.PHONY: kylo-ui
kylo-ui:
		mkdir -p docker/kylo-ui/dist/kylo-ui
		cp -R ../kylok8s/install/install-tar/target/kylo/kylo-ui/lib docker/kylo-ui/dist/kylo-ui
		cp -R ../kylok8s/install/install-tar/target/kylo/kylo-ui/plugin docker/kylo-ui/dist/kylo-ui
		cp -R ../kylok8s/install/install-tar/target/kylo/bin docker/kylo-ui/dist
		cp -R ../kylok8s/install/install-tar/target/kylo/lib docker/kylo-ui/dist
		docker build -t tba-kylo-ui -f docker/kylo-ui/Dockerfile docker/kylo-ui
		docker tag tba-kylo-ui $(REGISTRY)/tba-kylo-ui.8.4:1.1.0
		docker push $(REGISTRY)/tba-kylo-ui.8.4:1.1.0
		rm -dr docker/kylo-ui/dist

.PHONY: nifi
nifi:
		mkdir -p docker/nifi/dist/daf
		cp -R ../kylok8s/install/install-tar/target/kylo/setup/nifi/* docker/nifi/dist
		cp -R ../daf-kylo8s/nifi/extensions/processors/target/*.nar docker/nifi/dist/daf
		docker build -t tba-nifi -f docker/nifi/Dockerfile docker/nifi
		docker tag tba-nifi $(REGISTRY)/tba-nifi.1.4.0:1.1.1-SNAPSHOT
		docker push $(REGISTRY)/tba-nifi.1.4.0:1.1.1-SNAPSHOT
		rm -dr docker/nifi/dist

.PHONY: build-kylo
build-kylo:
	git clone https://github.com/italia/kylo.git ../kylok8s | true
	cd ../kylok8s && \
	git checkout release/0.8.4-daf-kylo && \
	git pull && \
	mvn clean install -DskipTests && \
	mkdir install/install-tar/target/kylo && \
	tar -C install/install-tar/target/kylo -xvf install/install-tar/target/kylo-*-dependencies.tar.gz

.PHONY: daf-kylo
daf-kylo:
	git clone https://github.com/italia/daf-kylo.git ../daf-kylo8s | true
	cd ../daf-kylo8s && \
    git checkout master && \
    git pull && \
    cd nifi/extensions && \
    mvn clean install


clean:
	rm -rf ../daf-kylo8s
	rm -rf ../kylok8s
	rm -rf docker
