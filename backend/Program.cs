using backend.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
// Swagger/OpenAPI (Swashbuckle)
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configurar Entity Framework Core con SQL Server
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=(localdb)\\MSSQLLocalDB;Database=practicadb;Integrated Security=true;";

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
