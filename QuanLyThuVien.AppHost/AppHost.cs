using Aspire.Hosting;

var builder = DistributedApplication.CreateBuilder(args);

var database = builder.AddConnectionString("Database");

var server = builder.AddProject<Projects.QuanLyThuVien_Server>("Backend")
    .WithHttpEndpoint(port: 5000)
    .WithHttpsEndpoint(port: 5001)
    .WithReference(database)
    .WithHttpHealthCheck("/health")
    .WithUrlForEndpoint("http", url => url.Url += "/api-docs")
    .WithUrlForEndpoint("https", url => url.Url += "/api-docs");

var webfrontend = builder.AddViteApp("Frontend", "../frontend")
    .WithHttpEndpoint(port: 5173)
    .WithReference(server)
    .WithEnvironment("SERVER_HTTP", server.GetEndpoint("http"))
    .WithEnvironment("SERVER_HTTPS", server.GetEndpoint("https"))
    .WaitFor(server);

server.PublishWithContainerFiles(webfrontend, "wwwroot");

builder.Build().Run();
