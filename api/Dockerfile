FROM mhart/alpine-node:9

RUN npm install -g postgraphile
ARG API_WORKDIR
WORKDIR $API_WORKDIR

ENTRYPOINT ["sh", "start.sh"]
