FROM mhart/alpine-node:9

RUN npm install -g postgraphile
WORKDIR /var/app
COPY start.sh .

ENTRYPOINT ["sh", "start.sh"]
