#Start with build image
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env
WORKDIR /app

#install node
ENV NODE_VER=16.15.1
RUN apt-get install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "${NVM_DIR}/nvm.sh" && nvm install ${NODE_VER}
RUN . "${NVM_DIR}/nvm.sh" && nvm use v${NODE_VER}
RUN . "${NVM_DIR}/nvm.sh" && nvm alias default v${NODE_VER}
ENV PATH="/root/.nvm/versions/node/v${NODE_VER}/bin:$PATH"

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o out

#Create and copy final image, set env variables
FROM mcr.microsoft.com/dotnet/sdk:5.0

#install aws-cli
WORKDIR /aws
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

ENV ASPNETCORE_URLS=http://+:80;https://+:443
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_HTTPS_PORT=9797
ENV ASPNETCORE_Kestrel__Certificates__Default__Path=/https/cert.crt
ENV ASPNETCORE_Kestrel__Certificates__Default__KeyPath=/https/key.pem
ENV ASPNETCORE_Kestrel__Certificates__Default__Password=""

WORKDIR /app
COPY --from=build-env app/out .

#http
EXPOSE 9796/tcp
#https
EXPOSE 9797/tcp

ENTRYPOINT ["dotnet", "wswp-app.dll"]