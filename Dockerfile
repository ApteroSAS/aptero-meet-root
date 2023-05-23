FROM node:18-alpine
RUN apk add git openssh

#teams-module
COPY packages/teams-module/package.json packages/teams-module/package.json
COPY packages/teams-module/yarn.lock packages/teams-module/yarn.lock
#basic-modules
COPY packages/basic-modules/package.json packages/basic-modules/package.json
COPY packages/basic-modules/yarn.lock packages/basic-modules/yarn.lock
# aptero-meet
COPY packages/Aptero-Meet/package.json packages/Aptero-Meet/package.json
COPY packages/Aptero-Meet/yarn.lock packages/Aptero-Meet/yarn.lock
#root config
COPY package.json .
COPY yarn.lock .
#install
RUN yarn

#build
COPY . .
RUN yarn run build
RUN cp -r packages/Aptero-Meet/dist ./dist

FROM nginx:1.21.3-alpine
RUN mkdir /usr/share/nginx/html/data
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY --from=0 ./dist/ /usr/share/nginx/html/
