from elixir:1.9-alpine

ENV UID=911 GID=911 MIX_ENV=PROD

ARG CHECKOUT=develop

RUN apk -U upgrade \
  && apk add --no-cache \
  build-base \
  git

RUN addgroup -g ${GID} pleroma \
  && adduser -h /pleroma -s /bin/sh -D -G pleroma -u ${UID} pleroma

USER pleroma
WORKDIR pleroma

RUN git clone -b develop https://git.pleroma.social/pleroma/pleroma.git /plroma \
  && git checkout ${CHECKOUT}

COPY config/secret.exs /pleroma/config/prod.secret.exs

RUN mix local.rebar --force \
  && mix local.hex --force \
  && mix deps.get \
  && mix compile

VOLUME /pleroma/uploads

CMD ["mix", "phx.server"]