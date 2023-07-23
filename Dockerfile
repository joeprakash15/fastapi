# Writting a Dockerfile for our application that used to build as a docker image. And that docker image used run as a container (pod) into k8s platform. 

# pull official base image, i am using alpine image to reduce the images size.  

FROM python:3.8.1-alpine

# set work directory -inside the container 
WORKDIR /src

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# copy requirements file
COPY ./requirements.txt /src/requirements.txt

# install dependencies
RUN set -eux \
    && apk add --no-cache --virtual .build-deps build-base \
    libressl-dev libffi-dev gcc musl-dev python3-dev \
    postgresql-dev \
    && pip install --upgrade pip setuptools wheel \
    && pip install -r /src/requirements.txt \
    && rm -rf /root/.cache/pip

# copy project into container's working directory 
COPY ./app /src/app

# set the default command to run the FastAPI server using uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
