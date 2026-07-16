using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyBooks.Service.Migrations
{
    public partial class AddNivoToZnacka : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Citat__IdKnjiga__29572725",
                table: "Citat");

            migrationBuilder.DropForeignKey(
                name: "FK__KnjigaZan__IdKnj__2E1BDC42",
                table: "KnjigaZanr");

            migrationBuilder.DropForeignKey(
                name: "FK__KnjigaZan__IdZan__2F10007B",
                table: "KnjigaZanr");

            migrationBuilder.AddColumn<int>(
                name: "KorisnikId",
                table: "WishKnjiga",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AlterColumn<string>(
                name: "Mood",
                table: "Knjiga",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<bool>(
                name: "IsFavorite",
                table: "Knjiga",
                type: "bit",
                nullable: true,
                defaultValueSql: "((0))",
                oldClrType: typeof(bool),
                oldType: "bit");

            migrationBuilder.AddColumn<string>(
                name: "Biljeske",
                table: "Knjiga",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "KorisnikId",
                table: "Knjiga",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "KorisnikId",
                table: "Citat",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "Korisnik",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ime = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    LozinkaHash = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    LozinkaSalt = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    DatumRegistracije = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())"),
                    ProfilnaSlika = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    GodisnjiCilj = table.Column<int>(type: "int", nullable: true, defaultValueSql: "((20))"),
                    OmiljeniZanrId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Korisnik", x => x.Id);
                    table.ForeignKey(
                        name: "FK__Korisnik__Omilje__29572725",
                        column: x => x.OmiljeniZanrId,
                        principalTable: "Zanr",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Znacka",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Opis = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    Ikonica = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    Tip = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    Prag = table.Column<int>(type: "int", nullable: false),
                    Nivo = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Znacka", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "KorisnikZnacka",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    ZnackaId = table.Column<int>(type: "int", nullable: false),
                    DatumOtkljucavanja = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_KorisnikZnacka", x => x.Id);
                    table.ForeignKey(
                        name: "FK__KorisnikZ__Koris__412EB0B6",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK__KorisnikZ__Znack__4222D4EF",
                        column: x => x.ZnackaId,
                        principalTable: "Znacka",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_WishKnjiga_KorisnikId",
                table: "WishKnjiga",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Knjiga_KorisnikId",
                table: "Knjiga",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Citat_KorisnikId",
                table: "Citat",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Korisnik_OmiljeniZanrId",
                table: "Korisnik",
                column: "OmiljeniZanrId");

            migrationBuilder.CreateIndex(
                name: "UQ__Korisnik__A9D10534CE4A337D",
                table: "Korisnik",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_KorisnikZnacka_KorisnikId",
                table: "KorisnikZnacka",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_KorisnikZnacka_ZnackaId",
                table: "KorisnikZnacka",
                column: "ZnackaId");

            migrationBuilder.AddForeignKey(
                name: "FK__Citat__IdKnjiga__33D4B598",
                table: "Citat",
                column: "IdKnjiga",
                principalTable: "Knjiga",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK__Citat__KorisnikI__32E0915F",
                table: "Citat",
                column: "KorisnikId",
                principalTable: "Korisnik",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK__Knjiga__Korisnik__2E1BDC42",
                table: "Knjiga",
                column: "KorisnikId",
                principalTable: "Korisnik",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK__KnjigaZan__IdKnj__36B12243",
                table: "KnjigaZanr",
                column: "IdKnjiga",
                principalTable: "Knjiga",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK__KnjigaZan__IdZan__37A5467C",
                table: "KnjigaZanr",
                column: "IdZanr",
                principalTable: "Zanr",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK__WishKnjig__Koris__3B75D760",
                table: "WishKnjiga",
                column: "KorisnikId",
                principalTable: "Korisnik",
                principalColumn: "Id");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Citat__IdKnjiga__33D4B598",
                table: "Citat");

            migrationBuilder.DropForeignKey(
                name: "FK__Citat__KorisnikI__32E0915F",
                table: "Citat");

            migrationBuilder.DropForeignKey(
                name: "FK__Knjiga__Korisnik__2E1BDC42",
                table: "Knjiga");

            migrationBuilder.DropForeignKey(
                name: "FK__KnjigaZan__IdKnj__36B12243",
                table: "KnjigaZanr");

            migrationBuilder.DropForeignKey(
                name: "FK__KnjigaZan__IdZan__37A5467C",
                table: "KnjigaZanr");

            migrationBuilder.DropForeignKey(
                name: "FK__WishKnjig__Koris__3B75D760",
                table: "WishKnjiga");

            migrationBuilder.DropTable(
                name: "KorisnikZnacka");

            migrationBuilder.DropTable(
                name: "Korisnik");

            migrationBuilder.DropTable(
                name: "Znacka");

            migrationBuilder.DropIndex(
                name: "IX_WishKnjiga_KorisnikId",
                table: "WishKnjiga");

            migrationBuilder.DropIndex(
                name: "IX_Knjiga_KorisnikId",
                table: "Knjiga");

            migrationBuilder.DropIndex(
                name: "IX_Citat_KorisnikId",
                table: "Citat");

            migrationBuilder.DropColumn(
                name: "KorisnikId",
                table: "WishKnjiga");

            migrationBuilder.DropColumn(
                name: "Biljeske",
                table: "Knjiga");

            migrationBuilder.DropColumn(
                name: "KorisnikId",
                table: "Knjiga");

            migrationBuilder.DropColumn(
                name: "KorisnikId",
                table: "Citat");

            migrationBuilder.AlterColumn<string>(
                name: "Mood",
                table: "Knjiga",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(100)",
                oldMaxLength: 100,
                oldNullable: true);

            migrationBuilder.AlterColumn<bool>(
                name: "IsFavorite",
                table: "Knjiga",
                type: "bit",
                nullable: false,
                defaultValue: false,
                oldClrType: typeof(bool),
                oldType: "bit",
                oldNullable: true,
                oldDefaultValueSql: "((0))");

            migrationBuilder.AddForeignKey(
                name: "FK__Citat__IdKnjiga__29572725",
                table: "Citat",
                column: "IdKnjiga",
                principalTable: "Knjiga",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK__KnjigaZan__IdKnj__2E1BDC42",
                table: "KnjigaZanr",
                column: "IdKnjiga",
                principalTable: "Knjiga",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK__KnjigaZan__IdZan__2F10007B",
                table: "KnjigaZanr",
                column: "IdZanr",
                principalTable: "Zanr",
                principalColumn: "Id");
        }
    }
}
