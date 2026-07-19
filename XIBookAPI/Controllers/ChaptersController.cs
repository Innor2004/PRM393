using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhysicsBook.Data;

namespace PhysicsBook.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChaptersController : ControllerBase
{
    private readonly AppDbContext _db;

    public ChaptersController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<ActionResult> GetChapters()
    {
        var chapters = await _db.Chapters
            .OrderBy(c => c.OrderIndex)
            .Select(c => new
            {
                c.Id,
                c.BookId,
                c.Title,
                c.Description,
                c.OrderIndex
            })
            .ToListAsync();
        return Ok(new { data = chapters });
    }

    [HttpGet("{id}/lessons")]
    public async Task<ActionResult> GetLessons(long id)
    {
        var lessons = await _db.Lessons
            .Where(l => l.ChapterId == id)
            .OrderBy(l => l.OrderIndex)
            .Select(l => new
            {
                l.Id,
                l.ChapterId,
                l.Title,
                l.OrderIndex,
                l.EstimatedMinutes,
                l.DifficultyStars,
                l.ContentBody
            })
            .ToListAsync();
        return Ok(new { data = lessons });
    }
}

