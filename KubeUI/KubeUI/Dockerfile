FROM microsoft/dotnet:2.2-sdk as builder

WORKDIR /app
EXPOSE 80

COPY *.csproj ./
RUN dotnet restore

COPY . .
RUN dotnet publish -c Release -o /out *.csproj

#app image
FROM microsoft/dotnet:2.2-aspnetcore-runtime

WORKDIR /app
ENTRYPOINT ["dotnet", "KubeUI.dll"]

COPY --from=builder /out .