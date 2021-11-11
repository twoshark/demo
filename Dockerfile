FROM mcr.microsoft.com/dotnet/sdk:6.0 as builder
# for dotnet builds it is critical that you do not use the root dir `/` as your WORKDIR
WORKDIR /app 

# Copy in project files only first to pull nuget deps
COPY *.csproj .
RUN dotnet restore --disable-parallel -v diag

#Copy source for build/publish
COPY . . 
RUN dotnet publish . -c Release -o /out --no-restore -p:PublishSingleFile=true -r linux-x64

FROM debian:latest as final
WORKDIR /app
EXPOSE 8080

RUN apt update -y
RUN apt install libssl-dev -y

COPY --from=builder /out .
RUN chmod +x demo
ENTRYPOINT ["./demo"]
