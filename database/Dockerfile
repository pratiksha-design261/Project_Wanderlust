#base image for mongobd from github repo
FROM mongo

# it will create new folder in current directory
WORKDIR mongo

#copy all data availabe to this flder to current Workingdir
COPY . .

# this cmd will start server automitically 
#entrypoint it used as we dont ike to override parrameter in any case 
ENTRYPOINT [ "mongod" ]