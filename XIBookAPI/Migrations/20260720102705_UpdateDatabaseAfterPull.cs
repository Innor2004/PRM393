using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace XIBookAPI.Migrations
{
    /// <inheritdoc />
    public partial class UpdateDatabaseAfterPull : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Progress_Lessons_LessonId",
                table: "Progress");

            migrationBuilder.DropForeignKey(
                name: "FK_Progress_Users_UserId",
                table: "Progress");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Progress",
                table: "Progress");

            migrationBuilder.RenameTable(
                name: "Progress",
                newName: "Progresses");

            migrationBuilder.RenameIndex(
                name: "IX_Progress_UserId",
                table: "Progresses",
                newName: "IX_Progresses_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_Progress_LessonId",
                table: "Progresses",
                newName: "IX_Progresses_LessonId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Progresses",
                table: "Progresses",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Progresses_Lessons_LessonId",
                table: "Progresses",
                column: "LessonId",
                principalTable: "Lessons",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Progresses_Users_UserId",
                table: "Progresses",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Progresses_Lessons_LessonId",
                table: "Progresses");

            migrationBuilder.DropForeignKey(
                name: "FK_Progresses_Users_UserId",
                table: "Progresses");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Progresses",
                table: "Progresses");

            migrationBuilder.RenameTable(
                name: "Progresses",
                newName: "Progress");

            migrationBuilder.RenameIndex(
                name: "IX_Progresses_UserId",
                table: "Progress",
                newName: "IX_Progress_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_Progresses_LessonId",
                table: "Progress",
                newName: "IX_Progress_LessonId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Progress",
                table: "Progress",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Progress_Lessons_LessonId",
                table: "Progress",
                column: "LessonId",
                principalTable: "Lessons",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Progress_Users_UserId",
                table: "Progress",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
