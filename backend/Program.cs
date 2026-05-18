using backend.Data;
using Microsoft.EntityFrameworkCore;

using System.Diagnostics; //para usar datos del sistema

var builder = WebApplication.CreateBuilder(args);

string wslHost = "localhost"; 
try
{
    // lee la IP asignada por WSL al Windows real sobre la marcha
    var process = new Process
    {
        StartInfo = new ProcessStartInfo
        {
            FileName = "sh",
            Arguments = "-c \"ip route | grep default | awk '{print $3}'\"",
            RedirectStandardOutput = true,
            UseShellExecute = false,
            CreateNoWindow = true,
        }
    };
    process.Start();
    string output = process.StandardOutput.ReadToEnd().Trim();
    process.WaitForExit();

    if (!string.IsNullOrEmpty(output))
    {
        wslHost = output; // si usamos la IP dinamica la usamos
    }
}
catch
{
    wslHost = "localhost"; // Fallback por si acaso
}
// Add services to the container.
builder.Services.AddControllers();
// Swagger/OpenAPI (Swashbuckle)
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configurar Entity Framework Core con SQL Server
var connectionString = $"Server={wslHost},1433;Database=GreenFix;User Id=greenfix_user;Password=GreenFix123!;TrustServerCertificate=True;";

builder.Services.AddDbContext<GreenFixDbContext>(options =>
    options.UseSqlServer(connectionString));

// Note: Removed AddOpenApi to avoid conflicts with Swashbuckle
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    // Enable Swagger (OpenAPI) middleware and UI in Development
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");

// Only enable HTTPS redirection when the host environment is Development
// or when an HTTPS endpoint is configured. This avoids the middleware
// warning "Failed to determine the https port for redirect" when the
// app is running with only an HTTP endpoint (common in simple local runs).
if (app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseAuthorization();
app.MapControllers();

app.Run();
