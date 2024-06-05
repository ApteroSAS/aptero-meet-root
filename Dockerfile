FROM node:22

RUN apt update -y
RUN apt install -y jq

WORKDIR /app

# Enable Corepack
RUN corepack enable

#teams-module
COPY packages/teams-module/package.json packages/teams-module/package.json
#COPY packages/teams-module/yarn.lock packages/teams-module/yarn.lock
COPY packages/teams-module/.yarnrc.yml packages/teams-module/.yarnrc.yml
#basic-modules
COPY packages/basic-modules/package.json packages/basic-modules/package.json
#COPY packages/basic-modules/yarn.lock packages/basic-modules/yarn.lock
COPY packages/basic-modules/.yarnrc.yml packages/basic-modules/.yarnrc.yml
# aptero-meet
COPY packages/Aptero-Meet/package.json packages/Aptero-Meet/package.json
#COPY packages/Aptero-Meet/yarn.lock packages/Aptero-Meet/yarn.lock
COPY packages/Aptero-Meet/.yarnrc.yml packages/Aptero-Meet/.yarnrc.yml

#root config
COPY package.json .
COPY yarn.lock .
COPY .yarnrc.yml .

#be sure to use yarn 2
COPY .yarn ./.yarn

#install
#RUN yarn --install-from-yarn-lock
RUN yarn install --immutable
#RUN yarn install

#build
COPY . .

COPY lerna.json .
#set useNx to false
RUN jq '.useNx = false' lerna.json > temp.json && mv temp.json lerna.json

RUN yarn run build
RUN cp -r packages/Aptero-Meet/dist ./dist

FROM nginx:1.21.3-alpine
RUN mkdir /usr/share/nginx/html/data
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY --from=0 /app/dist/ /usr/share/nginx/html/
