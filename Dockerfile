FROM debian:bookworm

LABEL maintainer="0x6A4B <0x6A4B@proton.me>"

# Updating package sources
RUN apt update && \
    apt -qy full-upgrade && \
    apt install -qy git && \
    apt install -qy wget && \
# Install a basic SSH server
    apt install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Installing JDK 21
   # apt-get install -qy openjdk-21-jdk && \
    mkdir temp && cd $_ && \
    wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb && \
    dpkg -i jdk-21_linux-x64_bin.deb && \
# Install Maven 3.9.9
    wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz && \
    tar xvf apache-maven-3.9.9-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.9.9 /opt/maven && \
    ln -s /opt/maven/bin/mvn /bin/mvn && \
    cd .. && rm -r temp && \
# Package cleanup
    apt-get -qy autoremove

# Add jenkins user
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins && \
# Set password for the jenkins user (you may want to alter this).
    echo "jenkins:jenkins" | chpasswd && \
    mkdir /home/jenkins/.m2

# Copy Jenkins settings file
#COPY settings.xml /home/jenkins/.m2/

# Copy authorized keys
COPY authorized_keys /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.m2/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
