using Microsoft.EntityFrameworkCore;
using MyBooks.Models;
using MyBooks.Service;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddDbContext<MyBooks.Service.Database.MyBooksContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("MyBooks")));
builder.Services.AddAutoMapper(typeof(IKnjigaService));
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle

builder.Services.AddTransient<IKnjigaService, KnjigaService>(); //plus dodat sve ostalo
builder.Services.AddTransient<IZanrService, ZanrService>();
builder.Services.AddTransient<ICitatService, CitatService>();
builder.Services.AddTransient<IWishKnjigaService, WishKnjigaService>();
builder.Services.AddTransient<IKnjigaZanrService, KnjigaZanrService>();

builder.Services.AddTransient<IKorisnikService, KorisnikService>();
//builder.Services.AddTransient<IZnackaService, ZnackaService>();
//builder.Services.AddTransient<IKorisnikZnackaService, KorisnikZnackaService>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

//app.UseAuthorization();

app.MapControllers();

app.Run();
