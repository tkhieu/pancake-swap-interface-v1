# pull official base image
FROM node:14-alpine AS builder

# set working directory
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# install app dependencies
COPY package.json ./

COPY yarn.lock ./

RUN apk add git python gcc make libc-dev python g++

RUN yarn install

COPY . .

RUN yarn build

FROM nginx:stable-alpine

COPY --from=builder /app/build/ /usr/share/nginx/html

COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template

RUN apk add gettext bash

CMD /bin/bash -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'