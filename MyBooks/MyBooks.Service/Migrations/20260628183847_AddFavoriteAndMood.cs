using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyBooks.Service.Migrations
{
    public partial class AddFavoriteAndMood : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsFavorite",
                table: "Knjiga",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Mood",
                table: "Knjiga",
                type: "nvarchar(max)",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsFavorite",
                table: "Knjiga");

            migrationBuilder.DropColumn(
                name: "Mood",
                table: "Knjiga");
        }
    }
}
