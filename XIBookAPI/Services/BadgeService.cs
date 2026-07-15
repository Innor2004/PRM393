using Microsoft.EntityFrameworkCore;
using PhysicsBook.Data;
using PhysicsBook.Models;

namespace PhysicsBook.Services;

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

        var lessonIdsWithQuestions = await _db.Questions
            .Select(q => q.LessonId)
            .Distinct()
            .ToListAsync();

        var completedLessonIds = await _db.Progresses
            .Where(p => p.UserId == userId && p.IsCompleted)
            .Select(p => p.LessonId)
            .Distinct()
            .ToListAsync();

        var noQuizLessonIds = (await _db.Lessons
            .Select(l => l.Id)
            .ToListAsync())
            .Except(lessonIdsWithQuestions)
            .ToList();

        foreach (var lessonId in noQuizLessonIds)
        {
            if (!completedLessonIds.Contains(lessonId))
            {
                var progress = new Progress
                {
                    UserId = userId,
                    LessonId = lessonId,
                    IsCompleted = true,
                    QuizScore = null,
                    CompletionPercent = 100,
                    UpdatedAt = DateTime.UtcNow
                };
                _db.Progresses.Add(progress);
            }
        }

        if (noQuizLessonIds.Any())
            await _db.SaveChangesAsync();

        var allCompletedCount = await _db.Progresses
            .Where(p => p.UserId == userId && p.IsCompleted)
            .Select(p => p.LessonId)
            .Distinct()
            .CountAsync();

        if (allCompletedCount < totalLessons) return;

        var avgScore = await _db.Progresses
            .Where(p => p.UserId == userId && p.IsCompleted && p.QuizScore != null)
            .AverageAsync(p => (double?)p.QuizScore) ?? 0;

        var avgPercent = avgScore * 10;

        var eligibleBadgeIds = await _db.Badges
            .Where(b => b.RequiredScore <= (int)avgPercent)
            .Select(b => b.Id)
            .ToListAsync();

        var earnedBadgeIds = await _db.UserBadges
            .Where(ub => ub.UserId == userId)
            .Select(ub => ub.BadgeId)
            .ToListAsync();

        var newBadgeIds = eligibleBadgeIds.Except(earnedBadgeIds).ToList();
        foreach (var badgeId in newBadgeIds)
        {
            _db.UserBadges.Add(new UserBadge
            {
                UserId = userId,
                BadgeId = badgeId,
                EarnedAt = DateTime.UtcNow
            });
        }

        var revokeBadgeIds = earnedBadgeIds.Except(eligibleBadgeIds).ToList();
        if (revokeBadgeIds.Any())
        {
            var toRemove = await _db.UserBadges
                .Where(ub => ub.UserId == userId && revokeBadgeIds.Contains(ub.BadgeId))
                .ToListAsync();
            _db.UserBadges.RemoveRange(toRemove);
        }

        await _db.SaveChangesAsync();
    }
}

