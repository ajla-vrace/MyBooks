using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyBooks.Service.Migrations
{
    public partial class AddSlikaToKnjiga : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Knjiga",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naslov = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Autor = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Opis = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Ocjena = table.Column<int>(type: "int", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    Recenzija = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DatumPocetka = table.Column<DateTime>(type: "date", nullable: true),
                    DatumZavrsetka = table.Column<DateTime>(type: "date", nullable: true),
                    DatumKreiranja = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())"),
                    Slika = table.Column<byte[]>(type: "varbinary(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Knjiga", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "WishKnjiga",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naslov = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Autor = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    Napomena = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Prioritet = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    DatumKreiranja = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WishKnjiga", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Zanr",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Zanr", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Citat",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    IdKnjiga = table.Column<int>(type: "int", nullable: false),
                    TekstCitata = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    BrojStranice = table.Column<int>(type: "int", nullable: true),
                    JeOmiljeni = table.Column<bool>(type: "bit", nullable: true, defaultValueSql: "((0))"),
                    DatumKreiranja = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Citat", x => x.Id);
                    table.ForeignKey(
                        name: "FK__Citat__IdKnjiga__29572725",
                        column: x => x.IdKnjiga,
                        principalTable: "Knjiga",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "KnjigaZanr",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    IdKnjiga = table.Column<int>(type: "int", nullable: false),
                    IdZanr = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_KnjigaZanr", x => x.Id);
                    table.ForeignKey(
                        name: "FK__KnjigaZan__IdKnj__2E1BDC42",
                        column: x => x.IdKnjiga,
                        principalTable: "Knjiga",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK__KnjigaZan__IdZan__2F10007B",
                        column: x => x.IdZanr,
                        principalTable: "Zanr",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Citat_IdKnjiga",
                table: "Citat",
                column: "IdKnjiga");

            migrationBuilder.CreateIndex(
                name: "IX_KnjigaZanr_IdKnjiga",
                table: "KnjigaZanr",
                column: "IdKnjiga");

            migrationBuilder.CreateIndex(
                name: "IX_KnjigaZanr_IdZanr",
                table: "KnjigaZanr",
                column: "IdZanr");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Citat");

            migrationBuilder.DropTable(
                name: "KnjigaZanr");

            migrationBuilder.DropTable(
                name: "WishKnjiga");

            migrationBuilder.DropTable(
                name: "Knjiga");

            migrationBuilder.DropTable(
                name: "Zanr");
        }
    }
}
