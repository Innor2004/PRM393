using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace XIBookAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddDifficultyStarsToLesson : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "DifficultyStars",
                table: "Lessons",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DifficultyStars",
                table: "Lessons");
        }
    }
}
