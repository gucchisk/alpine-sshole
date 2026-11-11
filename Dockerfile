FROM alpine:3.24.4 AS openssh_builder

RUN apk add alpine-sdk git
RUN git clone --depth 1 --branch v3.24.3 https://gitlab.alpinelinux.org/alpine/aports.git /aports
RUN abuild-keygen -a -n && cp /root/.abuild/*.rsa.pub /etc/apk/keys/
WORKDIR /aports/main/openssh
RUN abuild -F -r

FROM alpine:3.24.4

WORKDIR /app
RUN --mount=type=bind,from=openssh_builder,source=/root/packages/main,target=/tmp/openssh-packages \
    apk add --no-cache --allow-untrusted \
        /tmp/openssh-packages/*/openssh-server-[0-9]*.apk \
        /tmp/openssh-packages/*/openssh-server-common-[0-9]*.apk \
        /tmp/openssh-packages/*/openssh-keygen-[0-9]*.apk \
        /tmp/openssh-packages/*/openssh-client-common-[0-9]*.apk \
        /tmp/openssh-packages/*/openssh-client-default-[0-9]*.apk
RUN adduser -D alice
RUN echo 'alice:password' | chpasswd
# target: shadow のパスワード欄を "*"（無効ハッシュ）にして sshole のターゲットにする
RUN adduser -D target
RUN echo 'target:*' | chpasswd -e
RUN echo 'PermitRootLogin yes' > /etc/ssh/sshd_config.d/99-permit-root-login.conf
COPY ./entrypoint.sh ./

ENTRYPOINT [ "/app/entrypoint.sh" ]
