var builder = DistributedApplication.CreateBuilder(args);

var database = builder.AddSqlServer("Database")
                   .WithDataVolume()
                   .WithDbGate()
                   .AddDatabase("QuanLyThuVien");

var server = builder.AddProject<Projects.QuanLyThuVien_Server>("Backend")
    .WithReference(database)
    .WithHttpHealthCheck("/health")
    .WithExternalHttpEndpoints()
    .WithUrlForEndpoint("http", url => url.Url = "/api-docs")
    .WithUrlForEndpoint("https", url => url.Url = "/api-docs");

var webfrontend = builder.AddViteApp("Frontend", "../frontend")
    .WithReference(server)
    .WaitFor(server);

server.PublishWithContainerFiles(webfrontend, "wwwroot");

builder.Build().Run();
