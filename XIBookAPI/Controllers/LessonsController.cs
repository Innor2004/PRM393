using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using XIBookAPI.Data;

namespace XIBookAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class LessonsController : ControllerBase
{
    private readonly AppDbContext _db;

    public LessonsController(AppDbContext db) => _db = db;

    [HttpGet("{id}")]
    public async Task<ActionResult> GetLesson(long id)
    {
        var lesson = await _db.Lessons.FindAsync(id);
        if (lesson == null) return NotFound(new { message = "Không tìm thấy bài học" });
        return Ok(new { data = lesson });
    }

    [HttpGet("{id}/questions")]
    public async Task<ActionResult> GetQuestions(long id)
    {
        var questions = await _db.Questions
            .Where(q => q.LessonId == id)
            .Select(q => new
            {
                q.Id,
                q.LessonId,
                q.QuestionText,
                q.OptionA,
                q.OptionB,
                q.OptionC,
                q.OptionD,
                q.CorrectOption,
                q.Explanation
            })
            .ToListAsync();
        return Ok(new { data = questions });
    }
}
