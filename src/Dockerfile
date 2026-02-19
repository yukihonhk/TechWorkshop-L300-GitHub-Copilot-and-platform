# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy remaining source code and build
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Set non-root user for security
RUN adduser --disabled-password --gecos '' appuser

# Copy published output
COPY --from=build /app/publish .

# Expose port 8080 (App Service default for Linux containers)
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Switch to non-root user
USER appuser

ENTRYPOINT ["dotnet", "ZavaStorefront.dll"]
