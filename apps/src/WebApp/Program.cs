using Scalar.AspNetCore;
using System.Net.Mime;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks();
builder.Services.AddOpenApi();

var app = builder.Build();

app.MapHealthChecks("/healthz/live");
app.MapOpenApi();
app.MapScalarApiReference(options =>
{
    options.WithTheme(ScalarTheme.DeepSpace)
        .WithDefaultHttpClient(ScalarTarget.Shell, ScalarClient.Curl)
        .WithDarkMode()
        .WithDarkModeToggle()
        .WithTitle("EKS Hello World Demo");
});

app.MapGet("/", () => Results.Ok(new HelloWorldResponse("Hello, world!")))
    .WithSummary("Hello World message")
    .WithDescription("Reply with a hello world message")
    .WithTags("demo")
    .WithName("get-hello-world")
    .Produces<HelloWorldResponse>(contentType: MediaTypeNames.Application.Json);

await app.RunAsync();


// ReSharper disable once ClassNeverInstantiated.Global
internal record HelloWorldResponse(string Message);
