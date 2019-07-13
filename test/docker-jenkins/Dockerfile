FROM jenkins:2.60.3

ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false"

COPY plugins.txt /usr/share/jenkins/ref/
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt
