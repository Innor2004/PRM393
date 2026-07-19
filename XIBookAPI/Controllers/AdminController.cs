using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhysicsBook.Data;
using PhysicsBook.Models;

namespace PhysicsBook.Controllers;

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

    [HttpGet("users/{id}/progress")]
    public async Task<ActionResult> GetUserProgress(long id)
    {
        var user = await _db.Users.FindAsync(id);
        if (user == null) return NotFound(new { message = "Không tìm thấy học sinh" });

        var progresses = await _db.Progresses.Where(p => p.UserId == id).ToListAsync();

        var chapters = await _db.Chapters
            .Include(c => c.Lessons)
            .OrderBy(c => c.OrderIndex)
            .ToListAsync();

        var resultChapters = chapters.Select(c => new
        {
            c.Id,
            c.Title,
            Lessons = c.Lessons.OrderBy(l => l.OrderIndex).Select(l =>
            {
                var p = progresses.FirstOrDefault(x => x.LessonId == l.Id);
                return new
                {
                    l.Id,
                    l.Title,
                    l.OrderIndex,
                    Progress = p != null ? new
                    {
                        p.IsCompleted,
                        p.QuizScore,
                        p.UpdatedAt
                    } : null
                };
            })
        });

        return Ok(new
        {
            data = new
            {
                user = new { user.Id, user.Name, user.Email },
                chapters = resultChapters
            }
        });
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
        lesson.DifficultyStars = updated.DifficultyStars;
        await _db.SaveChangesAsync();

        return Ok(new { data = lesson });
    }

    [HttpDelete("lessons/{id}")]
    public async Task<ActionResult> DeleteLesson(long id)
    {
        var lesson = await _db.Lessons.FindAsync(id);
        if (lesson == null) return NotFound();

        // Xóa tất cả các câu hỏi của bài học này bằng 1 truy vấn duy nhất
        await _db.Questions.Where(q => q.LessonId == id).ExecuteDeleteAsync();

        _db.Lessons.Remove(lesson);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPut("chapters/{id}")]
    public async Task<ActionResult> UpdateChapter(long id, Chapter updated)
    {
        var chapter = await _db.Chapters.FindAsync(id);
        if (chapter == null) return NotFound();

        chapter.Title = updated.Title;
        chapter.Description = updated.Description;
        await _db.SaveChangesAsync();

        return Ok(new { data = chapter });
    }

    [HttpDelete("chapters/{id}")]
    public async Task<ActionResult> DeleteChapter(long id)
    {
        var chapter = await _db.Chapters.FindAsync(id);
        if (chapter == null) return NotFound();

        // Xóa tất cả các câu hỏi thuộc các bài học của chương này bằng 1 truy vấn duy nhất (Tránh N+1 query)
        await _db.Questions.Where(q => q.Lesson!.ChapterId == id).ExecuteDeleteAsync();
        
        // Xóa tất cả các bài học của chương này bằng 1 truy vấn duy nhất
        await _db.Lessons.Where(l => l.ChapterId == id).ExecuteDeleteAsync();
        
        _db.Chapters.Remove(chapter);
        await _db.SaveChangesAsync();

        return NoContent();
    }

    [HttpPost("lessons")]
    public async Task<ActionResult> CreateLesson(Lesson lesson)
    {
        _db.Lessons.Add(lesson);
        await _db.SaveChangesAsync();
        return Ok(new { data = lesson });
    }

    [HttpPost("questions")]
    public async Task<ActionResult> CreateQuestion(Question question)
    {
        _db.Questions.Add(question);
        await _db.SaveChangesAsync();
        return Ok(new { data = question });
    }

    [HttpPut("questions/{id}")]
    public async Task<ActionResult> UpdateQuestion(long id, Question updated)
    {
        var question = await _db.Questions.FindAsync(id);
        if (question == null) return NotFound();

        question.QuestionText = updated.QuestionText;
        question.OptionA = updated.OptionA;
        question.OptionB = updated.OptionB;
        question.OptionC = updated.OptionC;
        question.OptionD = updated.OptionD;
        question.CorrectOption = updated.CorrectOption;
        question.Explanation = updated.Explanation;
        await _db.SaveChangesAsync();

        return Ok(new { data = question });
    }

    [HttpDelete("questions/{id}")]
    public async Task<ActionResult> DeleteQuestion(long id)
    {
        var question = await _db.Questions.FindAsync(id);
        if (question == null) return NotFound();

        _db.Questions.Remove(question);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet("stats/user-growth")]
    public async Task<ActionResult> GetUserGrowth()
    {
        var days = await _db.Users
            .GroupBy(u => u.CreatedAt.Date)
            .Select(g => new { date = g.Key, count = g.Count() })
            .OrderBy(x => x.date)
            .ToListAsync();

        return Ok(new { data = days });
    }

    [HttpGet("stats/lesson-scores")]
    public async Task<ActionResult> GetLessonScores()
    {
        var scores = await _db.Progresses
            .Where(p => p.QuizScore > 0)
            .GroupBy(p => p.LessonId)
            .Select(g => new
            {
                lessonId = g.Key,
                averageScore = Math.Round(g.Average(p => (double?)p.QuizScore) ?? 0, 1),
                attemptCount = g.Count()
            })
            .OrderByDescending(x => x.averageScore)
            .ToListAsync();

        return Ok(new { data = scores });
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

