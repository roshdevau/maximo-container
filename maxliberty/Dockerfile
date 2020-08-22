FROM websphere-liberty:19.0.0.12-full-java8-ibmjava
# Maximo Image
COPY --chown=1001:0 maximo/* /config/

RUN configure.sh

