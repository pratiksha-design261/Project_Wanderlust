#------------------------Stage 1 starting------------------------------------------------
# node :21 version base image added with alias Frontent_stage_1
FROM node:21 AS Frontent_stage_1

# Set working dir as app to store data on working node 
WORKDIR /app

# copy file starts with package and end with.json to working node(WN) current directory
COPY package*.json ./

# This cmd will install dependancy specified in package.json file on WN
RUN npm install

# THis cmd will copy remaining all code and paste to current working dir of WN
COPY . .

#------------------------Stage 2 starting------------------------------------------------
# node:21-slim base image is set as we already install large memory reuired function in above image    
FROM node:21-slim

# Set working dir as app to store data on working node 
WORKDIR /app

# copy all data from app folder of stage 1 compressed image to working directory
COPY --from=Frontent_stage_1 /app .

# env specific file is copied to env.local , By copying it to .env.local, you align with some frameworks that automatically load configuration from .env.local during runtime.
COPY .env.docker .env.local

# Node s frontend application is allow to run on 5173 port
EXPOSE 5173

# ("npm", "run", "dev") this will run the dev script from package.json || (--) it allow to apss additional argument || (--host) its mostly used to mke dev server accssible to outside world of docker container 
CMD ["npm", "run", "dev", "--", "--host"]