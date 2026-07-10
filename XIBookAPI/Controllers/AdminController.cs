using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using XIBookAPI.Data;
using XIBookAPI.Models;

namespace XIBookAPI.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    private readonly AppDbContext _db;

    public AdminController(AppDbContext db) => _db = db;

    [HttpGet("users")]
    public async Task<ActionResult> GetUsers()
    {
        var users = await _db.Users
            .Select(u => new
            {
                u.Id, u.Name, u.Email, u.Role, u.CreatedAt,
                CompletedLessons = u.Progresses.Count(p => p.IsCompleted),
                AverageScore = u.Progresses.Average(p => (double?)p.QuizScore) ?? 0
            })
            .ToListAsync();
        return Ok(new { data = users });
    }

    [HttpPost("chapters")]
    public async Task<ActionResult> CreateChapter(Chapter chapter)
    {
        _db.Chapters.Add(chapter);
        await _db.SaveChangesAsync();
        return Ok(new { data = chapter });
    }

    [HttpPut("lessons/{id}")]
    public async Task<ActionResult> UpdateLesson(long id, Lesson updated)
    {
        var lesson = await _db.Lessons.FindAsync(id);
        if (lesson == null) return NotFound();

        lesson.Title = updated.Title;
        lesson.ContentBody = updated.ContentBody;
        lesson.EstimatedMinutes = updated.EstimatedMinutes;
        await _db.SaveChangesAsync();

        return Ok(new { data = lesson });
    }

    [HttpDelete("lessons/{id}")]
    public async Task<ActionResult> DeleteLesson(long id)
    {
        var lesson = await _db.Lessons.FindAsync(id);
        if (lesson == null) return NotFound();

        _db.Lessons.Remove(lesson);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet("stats")]
    public async Task<ActionResult> GetStats()
    {
        var totalUsers = await _db.Users.CountAsync();
        var totalChapters = await _db.Chapters.CountAsync();
        var totalLessons = await _db.Lessons.CountAsync();
        var totalQuestions = await _db.Questions.CountAsync();

        return Ok(new
        {
            totalUsers,
            totalChapters,
            totalLessons,
            totalQuestions
        });
    }
}
