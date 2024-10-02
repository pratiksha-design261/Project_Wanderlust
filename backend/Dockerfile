#------------------------Stage 1 starting------------------------------------------------
# node :21 version base image added with alias Backend_stage_1
FROM node:21 AS Backend-stage-1

# Set working dir as app to store data on working node 
WORKDIR /app

# copy file all data to working node(WN) current directory
COPY . .

# This cmd will install dependancy specified in package.json file on WN
RUN npm install

#------------------------Stage 2 starting------------------------------------------------
# node:21-slim base image is set as we already install large memory reuired function in above image 
FROM node:21-slim

# Set working dir as app to store data on working node 
WORKDIR /app

# copy all data from app folder of stage 1 compressed image to working directory
COPY --from=Backend-stage-1 /app .

# env specific file is copied to env.local , By copying it to .env.local, you align with some frameworks that automatically load configuration from .env.local during runtime.
COPY .env.docker .env.local


# Node s backend application is allow to run on 8080 port
EXPOSE 8080

# it will run start script from package.json
CMD ["npm", "start"]