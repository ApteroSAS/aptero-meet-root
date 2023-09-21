import sys
import os
import json


f = open('docker.json',)
data = json.load(f)
dockerImage = data['image']
registry = data['registry']

c = os.system
os.chdir("..")
print(os.getcwd())


def get_first_valid_version(file_list):
    for file_name in file_list:
        try:
            with open(file_name, 'r') as file:
                data = json.load(file)
                if 'version' in data:
                    print("Version :" + data['version'] +" - "+ file_name)
                    return data['version']
        except FileNotFoundError:
            continue
    return "latest"  # Default to "latest" if no valid version is found in any file

if(sys.argv[1] == "build"):
    os.system("docker build -t "+dockerImage+" .")
elif(sys.argv[1] == "build_no_cache"):
    os.system("docker build --no-cache --progress=plain -t "+dockerImage+" .")
elif(sys.argv[1] == "publish"):
    try:
        version = sys.argv[2]
    except:
        files_to_check = ['packages/Aptero-Meet/version.json','version.json', 'package.json']
        version = get_first_valid_version(files_to_check)

    c("docker build -t "+dockerImage+" .")
    c("docker login")
    c("docker tag "+dockerImage+":latest "+registry+"/"+dockerImage+":latest")
    c("docker push "+registry+"/"+dockerImage+":latest")

    c("docker tag "+dockerImage+":latest "+registry+"/"+dockerImage+":"+version)
    c("docker push "+registry+"/"+dockerImage+":"+version)
    print("tag version :"+version)
else:
    print("invalid usage")
