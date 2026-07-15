using Microsoft.EntityFrameworkCore;
using XIBookAPI.Data;
using XIBookAPI.Models;

namespace XIBookAPI.Services;

public class BadgeService
{
    private readonly AppDbContext _db;

    public BadgeService(AppDbContext db)
    {
        _db = db;
    }

    public async Task CheckAndAwardBadges(long userId)
    {
        var totalLessons = await _db.Lessons.CountAsync();
        if (totalLessons == 0) return;

        var completedLessonCount = await _db.Progresses
            .Where(p => p.UserId == userId && p.IsCompleted)
            .Select(p => p.LessonId)
            .Distinct()
            .CountAsync();

        if (completedLessonCount < totalLessons) return;

        var avgScore = await _db.Progresses
            .Where(p => p.UserId == userId && p.IsCompleted)
            .AverageAsync(p => (double?)p.QuizScore) ?? 0;

        var avgPercent = avgScore * 10;

        var eligibleBadges = await _db.Badges
            .Where(b => b.RequiredAvgScore <= (int)avgPercent)
            .ToListAsync();

        var earnedBadgeIds = await _db.UserBadges
            .Where(ub => ub.UserId == userId)
            .Select(ub => ub.BadgeId)
            .ToListAsync();

        foreach (var badge in eligibleBadges)
        {
            if (!earnedBadgeIds.Contains(badge.Id))
            {
                _db.UserBadges.Add(new UserBadge
                {
                    UserId = userId,
                    BadgeId = badge.Id,
                    EarnedAt = DateTime.UtcNow
                });
            }
        }

        await _db.SaveChangesAsync();
    }
}
