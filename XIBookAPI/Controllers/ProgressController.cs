using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhysicsBook.Data;
using PhysicsBook.Models;
using PhysicsBook.Services;

namespace PhysicsBook.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ProgressController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly BadgeService _badgeService;

    public ProgressController(AppDbContext db, BadgeService badgeService)
    {
        _db = db;
        _badgeService = badgeService;
    }

    [HttpGet("me")]
    public async Task<ActionResult> GetMyProgress()
    {
        var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        await _badgeService.CheckAndAwardBadges(userId);

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

    [HttpPost("complete-lesson/{lessonId}")]
    public async Task<ActionResult> CompleteLesson(long lessonId)
    {
        var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var lessonExists = await _db.Lessons.AnyAsync(l => l.Id == lessonId);
        if (!lessonExists)
            return NotFound(new { message = "Không tìm thấy bài học" });

        var progress = await _db.Progresses
            .FirstOrDefaultAsync(p => p.UserId == userId && p.LessonId == lessonId);

        if (progress == null)
        {
            progress = new Progress { UserId = userId, LessonId = lessonId };
            _db.Progresses.Add(progress);
        }

        progress.IsCompleted = true;
        progress.QuizScore = null;
        progress.CompletionPercent = 100;
        progress.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        await _badgeService.CheckAndAwardBadges(userId);

        return Ok(new { message = "Đã hoàn thành bài học" });
    }
}

