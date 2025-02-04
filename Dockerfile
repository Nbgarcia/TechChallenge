# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy the project file and restore dependencies
COPY ["./Fiap.Api/Fiap.Api.csproj", "./"]
RUN dotnet restore "Fiap.Api.csproj"

# Copy the remaining source code
COPY ./Fiap.Api/ .

# Build and publish the application
RUN dotnet build "Fiap.Api.csproj" -c Release -o /app/build

RUN dotnet publish "Fiap.Api.csproj" -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS runtime
WORKDIR /app

COPY ./Fiap.Api/ .

ENV PATH="/root/.dotnet/tools:$PATH"
# Install EF Core tools
RUN dotnet tool install --global dotnet-ef

# Copy published application from build stage (if using multi-stage build, skip this)
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "Fiap.Api.dll"]