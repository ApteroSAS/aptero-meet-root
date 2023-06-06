FROM node:18

RUN apt update -y
RUN apt install -y jq

#teams-module
COPY packages/teams-module/package.json packages/teams-module/package.json
#basic-modules
COPY packages/basic-modules/package.json packages/basic-modules/package.json
# aptero-meet
COPY packages/Aptero-Meet/package.json packages/Aptero-Meet/package.json
#root config
COPY package.json .
COPY yarn.lock .

#install
RUN yarn

COPY lerna.json .
#set useNx to false
RUN jq '.useNx = false' lerna.json > temp.json && mv temp.json lerna.json

#build
COPY . .
RUN yarn run build
RUN cp -r packages/Aptero-Meet/dist ./dist

FROM nginx:1.21.3-alpine
RUN mkdir /usr/share/nginx/html/data
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY --from=0 ./dist/ /usr/share/nginx/html/
