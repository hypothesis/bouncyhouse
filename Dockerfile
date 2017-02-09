FROM gliderlabs/alpine:3.4
MAINTAINER Hypothes.is Project and contributors

# Install system build and runtime dependencies.
RUN apk-install ca-certificates curl nodejs python3

# Create the bouncer user, group, home directory and package directory.
RUN addgroup -S bouncer \
  && adduser -S -G bouncer -h /var/lib/bouncer bouncer
WORKDIR /var/lib/bouncer

# Copy packaging
COPY README.rst package.json requirements.txt ./

RUN npm install --production \
  && npm cache clean

RUN pip3 install --no-cache-dir -U pip \
  && pip3 install --no-cache-dir -r requirements.txt

COPY . .

# Persist the static directory.
VOLUME ["/var/lib/bouncer/bouncer/static"]

# Start the web server by default
EXPOSE 8000
USER bouncer
CMD ["gunicorn", "-b", "0.0.0.0:8000", "bouncer:app()"]
