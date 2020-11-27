FROM six8/pyinstaller-alpine as yq
ARG YQ_VERSION=2.10.0
ENV PATH="/pyinstaller:$PATH"
RUN pip install yq==${YQ_VERSION}
RUN pyinstaller --noconfirm --onefile --log-level DEBUG --clean --distpath /tmp/ $(which yq)

FROM alpine

COPY --from=yq /tmp/yq /usr/local/bin/yq

ARG JQ_VERSION=1.6

RUN wget -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 && \
    chmod +x /usr/local/bin/*

RUN apk add  alpine-sdk ruby-dev ruby curl\
&&  gem install jwt json \
&&  apk del alpine-sdk ruby-dev

COPY . /

RUN chmod +x /script.sh
CMD /script.sh