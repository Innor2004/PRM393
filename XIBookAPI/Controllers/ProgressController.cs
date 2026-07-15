using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using XIBookAPI.Data;

namespace XIBookAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ProgressController : ControllerBase
{
    private readonly AppDbContext _db;

    public ProgressController(AppDbContext db) => _db = db;

    [HttpGet("me")]
    public async Task<ActionResult> GetMyProgress()
    {
        var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var progress = await _db.Progresses
            .Where(p => p.UserId == userId)
            .Select(p => new
            {
                p.LessonId,
                p.IsCompleted,
                p.QuizScore,
                p.CompletionPercent,
                p.UpdatedAt
            })
            .ToListAsync();

        var totalLessons = await _db.Lessons.CountAsync();
        var completed = progress.Count(p => p.IsCompleted);
        double overallPercent = totalLessons > 0 ? (double)completed / totalLessons * 100 : 0;

        var badges = await _db.UserBadges
            .Where(ub => ub.UserId == userId)
            .Select(ub => new
            {
                ub.Badge.Id,
                ub.Badge.Name,
                ub.Badge.Description,
                ub.Badge.IconUrl,
                ub.EarnedAt
            })
            .ToListAsync();

        return Ok(new
        {
            data = progress,
            summary = new
            {
                totalLessons,
                completedLessons = completed,
                overallPercent = Math.Round(overallPercent, 1)
            },
            badges
        });
    }
}
