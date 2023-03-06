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
RUN dotnet publish -c Debug -o out

#Create and copy final image
FROM mcr.microsoft.com/dotnet/sdk:5.0
ENV ASPNETCORE_URLS=http://+:80
WORKDIR /app
COPY --from=build-env app/out .
EXPOSE 80
ENTRYPOINT ["dotnet", "wswp-app.dll"]