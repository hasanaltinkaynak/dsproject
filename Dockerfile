#set base image (host OS) -- we choose python 3.7 for code requirement
#base image has Ubuntu operating system, it comes with python3.7
#we'll use "apt-get" commands since it's ubuntu based operating system
#if it was Centos base operating system, we'd use "yum" commands instead of "apt-get" with "RUN" command
FROM python:3.7-slim-buster
#container running time zone environmental variable
ENV TZ=US/Eastern
#update the bas e image packages before install the required packages --
#don't run this command after you install your required packages. it might broke your env python librarires
RUN apt-get update
#set your time zone - we use env variable to make dynamic variables
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#create required folder in container
RUN mkdir -p /etc/dsdevops/
#install and upgrade pip package 
RUN pip3 install --no-cache-dir -U pip
#copy the requirements file into container
COPY requirements.txt /etc/dsdevops/
#install the packages which are defined in requirements file such as "lxml"
RUN pip install -r /etc/dsdevops/requirements.txt
#we need to install the aws cli package into container to be able to run AWS apis in code.
RUN pip3 --no-cache-dir install --upgrade awscli
#our code needs some data scients library in the code env. so we need to install them into container
#SPACY:
#spaCy is designed to help you do real work — to build real products, or gather real insights. 
#The library respects your time, and tries to avoid wasting it. It's easy to install, and its API is simple and productive.
RUN pip3 install --no-cache-dir -U spacy==2.2.1
#NLTK > Natural Language Toolkit
#NLTK is a leading platform for building Python programs to work with human language data. 
#It provides easy-to-use interfaces to over 50 corpora and lexical resources such as WordNet, 
#along with a suite of text processing libraries for classification, tokenization, stemming, tagging, parsing, and semantic reasoning, 
#wrappers for industrial-strength NLP libraries, and an active discussion forum.
RUN pip3 install --no-cache-dir -U nltk
#The GNU Compiler Collection (GCC) is a collection of compilers and libraries for C, C++, Objective-C, Fortran, Ada, Go , and D programming languages. 
#A lot of open-source projects, including the Linux kernel and GNU tools, are compiled using GCC.
RUN apt-get install gcc -y
#datetime.fromisoformat:
#It is the inverse of datetime.isoformat. Similar methods were added to the date and time types as well. 
#For those who need to support earlier versions of Python, a backport of these methods was needed.
#The purpose of this is to provide a perfect backport of the fromisoformat methods to earlier versions of Python, while still providing comparable performance.
RUN pip3 install backports-datetime-fromisoformat
#en_core_web_sm
#it is a small English pipeline trained on written web text (blogs, news, comments), that includes vocabulary, syntax and entities.
RUN python3 -m spacy download en_core_web_sm
#Copy the project folder into container, the folder includes all code related files like source code app.oy etc
COPY . /etc/dsdevops/
#install/run required python3 packages in the container. The packages are defined in install_models.py
RUN python3  /etc/dsdevops/install_models.py
#install/run required python3 packages in the container. The packages are defined in Requirements_RuleBased.txt such as  "Flask, boto3" etc.
RUN python3 -m pip install -r /etc/dsdevops/Requirements_RuleBased.txt
# set the working directory for your container. The main path will be this value whatever you set in the next command. for our case, main path will be /etc/dsdevops/.
# you can change,defined any path/name in the container. 
#Note: Container will run any command on the WORKDIR path.
WORKDIR /etc/dsdevops/
#After set up the container environment, run your source code with CMD command. pretend that our code file name is dsdevops.py and when we run our docker image, the code will be run with container starting.. 
#note: dsdevops.py file should be in WORKDIR path, otherwise the pyhton3 command will not find the dsdevops file to  run in the container or you need to define exact path of 
#CMD python3 dsdevops.py
#for our project we don't have a project file since we want to show dockerfile steps as purpose so we added the "ping command" to be able to have continuosly running container continuosly
CMD ping -t localhost
