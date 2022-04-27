FROM ubuntu:impish-20220404



RUN apt update && \

    DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-budgie-desktop xrdp locales sudo tigervnc-standalone-server && \

    adduser xrdp ssl-cert && \

    locale-gen en_US.UTF-8 && \

    update-locale LANG=en_US.UTF-8



ARG USER=om

ARG PASS=1234



RUN useradd -m $USER -p $(openssl passwd $PASS) && \

    usermod -aG sudo $USER && \

    chsh -s /bin/bash $USER

RUN sed -i '3 a echo "\

budgie-panel & budgie-wm --x11 & plank" > ~/.Xsession' /etc/xrdp/startwm.sh


RUN echo "#!/bin/sh\n\

export XDG_SESSION_DESKTOP=budgie-desktop\n\

export GNOME_SHELL_SESSION_MODE=ubuntu\n\

export XDG_SESSION_TYPE=x11\n\

export XDG_CURRENT_DESKTOP=Budgie:GNOME\n\

export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg" > /env && chmod 555 /env



RUN sed -i '3 a cp /env ~/.xsessionrc' /etc/xrdp/startwm.sh



RUN mkdir /home/$USER/.vnc && \

    echo $PASS | vncpasswd -f > /home/$USER/.vnc/passwd && \

    chmod 0600 /home/$USER/.vnc/passwd && \

    chown -R $USER:$USER /home/$USER/.vnc



RUN echo "#!/bin/sh\n\

. /env\n\

exec /etc/X11/xinit/xinitrc" > /home/$USER/.vnc/xstartup && chmod +x /home/$USER/.vnc/xstartup



RUN echo "#!/bin/sh\n\

sudo -u $USER -g $USER -- vncserver -rfbport 5901 -geometry 1920x1080 -depth 24 -verbose -localhost no -autokill no" > /startvnc && chmod +x /startvnc



EXPOSE 3389

EXPOSE 5901



CMD service dbus start; /usr/lib/systemd/systemd-logind & service xrdp start; /startvnc; bash
