FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM microsoft/dotnet:2.2-sdk AS build
WORKDIR /src
COPY KubeUI/KubeUI.csproj KubeUI/
RUN dotnet restore KubeUI/KubeUI.csproj
COPY . .
WORKDIR /src/KubeUI
RUN dotnet build KubeUI.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish KubeUI.csproj -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "KubeUI.dll"]
