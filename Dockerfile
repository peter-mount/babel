# ==============================================================================
# Docker image containing babel and eslint.
#
# This is used as a build image when compiling nodejs applications.
# It's a separate image as babel has a large number of dependencies and using
# this keeps the amount of downloads to a minimum.
#
# ==============================================================================
#
# How to use this:
#
# Here we'll have our application being build under the directory /opt/node
#
# --- Start Dockerfile
# FROM area51/${arch}-babel:latest as builder
#
# # Install project's dependencies in it's destination:
# ADD package.json /opt/node/
# RUN cd /opt/node && npm install
#
# # Now copy those modules into babel's directory so it's got access to it
# RUN cp -rp /opt/node/node_modules/* /root/node_modules/
#
# # Now import the source to compile
# ADD src /opt/babel/src/
#
# # Optional: Run lint against the source to check for errors
# RUN cd /opt/babel &&\
#     node ./node_modules/eslint/bin/eslint.js src
#
# # Run babel to compile
# RUN cd /opt/babel &&\
#     node ./node_modules/babel-cli/bin/babel.js \
#       --plugins transform-es2015-modules-umd \
#       src \
#       --ignore __tests__ \
#       --out-dir /opt/node
#
# # Now build the final image
#
# FROM area51/${arch}-node:latest
# LABEL maintainer="Peter Mount <peter@retep.org>"
#
# # Where our app is installed
# WORKDIR /opt/node
#
# # Copy the built app into it's final resting place
# COPY --from=builder /opt/node /opt/node/
#
# # Start the app - presuming index.js is the entry point here
# CMD ["node","index.js"]
#
# --- end Dockerfile
#
# ==============================================================================

# The default architecture
ARG arch=amd64

FROM area51/${arch}-node:latest

WORKDIR /opt/babel

# Install our build environment
ADD * /opt/babel/
#ADD package.json .
#ADD .babelrc .
#ADD .eslintrc .
RUN npm install
