FROM python:3.9-alpine3.13
LABEL maintainer="joesacco@me.com"

# recommended when running Python in Docker container
# don't buffer the output from Python.  Print it directly to console.
# this prevents delays
ENV PYTHONUNBUFFERED 1

# copy requirements file to location on container
COPY ./requirements.txt /tmp/requirements.txt

COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# copy app to location on container
COPY ./app /app

# default directory commands on docker image will be run from
WORKDIR /app

# expose port 8000 to machine to run container so we can access it
EXPOSE 8000

# By setting default dev argument to false, it is only overwritten when we build the image through our Docker Compose yml file, which specifies dev to be True
ARG DEV=false

# create new virtual env to install dependencies
RUN python -m venv /py && \
    # specify full path of virtual env
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    # install requirements file
    /py/bin/pip install -r /tmp/requirements.txt && \
    # if dev set to true run then code
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    # end if statement using fi
    fi && \
    # remove tmp directory to remove unneeded dependencies and keep image light
    rm -rf /tmp && \
    # add user (not root) - DON'T RUN APP USING ROOT USER   
    adduser \
        --disabled-password \
        # don't create home dir - keep it light
        --no-create-home \
        # user name
        django-user

# update ENV PATH variable in image
ENV PATH="/py/bin:$PATH"

# specifies user we are switching to from root user
USER django-user