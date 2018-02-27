# ============================================================
# The main babel image
FROM area51/node:latest as babel

ADD babel /usr/local/babel
ADD bin /usr/local/bin/

RUN cd /usr/local/babel &&\
    npm install &&\
    npm install -g \
      webpack \
      webpack-cli &&\
    chmod +x /usr/local/bin/*

# ============================================================
# the babel+react image
FROM babel as react

RUN cd /usr/local/babel/ &&\
    npm install \
      babel-preset-react \
      babel-preset-stage-0 \
      eslint-plugin-jsx-a11y \
      eslint-plugin-react
