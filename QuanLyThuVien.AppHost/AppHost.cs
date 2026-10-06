using Aspire.Hosting;

var builder = DistributedApplication.CreateBuilder(args);

var database = builder.AddConnectionString("Database");

var server = builder.AddProject<Projects.QuanLyThuVien_Server>("Backend")
    .WithReference(database)
    .WithHttpHealthCheck("/health")
    .WithUrlForEndpoint("http", url => url.Url += "/api-docs")
    .WithUrlForEndpoint("https", url => url.Url += "/api-docs");

var webfrontend = builder.AddViteApp("Frontend", "../frontend")
    .WithReference(server)
    .WaitFor(server);

server.PublishWithContainerFiles(webfrontend, "wwwroot");

builder.Build().Run();
