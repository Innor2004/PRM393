using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhysicsBook.Data;
using PhysicsBook.Models;
using PhysicsBook.Models.DTOs;
using PhysicsBook.Services;

namespace PhysicsBook.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class QuizController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly BadgeService _badgeService;

    public QuizController(AppDbContext db, BadgeService badgeService)
    {
        _db = db;
        _badgeService = badgeService;
    }

    [HttpPost("submit")]
    public async Task<ActionResult<QuizResultResponse>> Submit(QuizSubmitRequest request)
    {
        var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var questions = await _db.Questions
            .Where(q => q.LessonId == request.LessonId)
            .ToListAsync();

        if (questions.Count == 0)
            return BadRequest(new { message = "Không có câu hỏi cho bài học này" });

        var details = new List<AnswerResultDto>();
        int correctCount = 0;

        foreach (var q in questions)
        {
            var answer = request.Answers.FirstOrDefault(a => a.QuestionId == q.Id);
            var isCorrect = answer?.SelectedOption == q.CorrectOption;
            if (isCorrect) correctCount++;

            details.Add(new AnswerResultDto(
                q.Id, q.QuestionText, q.CorrectOption,
                answer?.SelectedOption, isCorrect, q.Explanation
            ));
        }

        double score = questions.Count > 0 ? (double)correctCount / questions.Count * 10 : 0;

        var attempt = new QuizAttempt
        {
            UserId = userId,
            LessonId = request.LessonId,
            Score = (decimal)score,
            CorrectCount = correctCount,
            TotalQuestions = questions.Count
        };

        foreach (var q in questions)
        {
            var answer = request.Answers.FirstOrDefault(a => a.QuestionId == q.Id);
            attempt.Details.Add(new QuizAttemptDetail
            {
                QuestionId = q.Id,
                SelectedOption = answer?.SelectedOption,
                IsCorrect = answer?.SelectedOption == q.CorrectOption
            });
        }
        _db.QuizAttempts.Add(attempt);

        var progress = await _db.Progresses
            .FirstOrDefaultAsync(p => p.UserId == userId && p.LessonId == request.LessonId);

        if (progress == null)
        {
            progress = new Progress { UserId = userId, LessonId = request.LessonId };
            _db.Progresses.Add(progress);
        }

        if (score >= 5)
        {
            progress.IsCompleted = true;
        }
        if (progress.QuizScore == null || (decimal)score > progress.QuizScore)
        {
            progress.QuizScore = (decimal)score;
            progress.CompletionPercent = (decimal)(score >= 5 ? 100 : score * 10);
        }
        progress.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        await _badgeService.CheckAndAwardBadges(userId);

        return Ok(new QuizResultResponse(
            score, correctCount, questions.Count, details
        ));
    }

    [HttpGet("history/{lessonId}")]
    public async Task<ActionResult<List<QuizAttemptDto>>> GetHistory(long lessonId)
    {
        var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var attempts = await _db.QuizAttempts
            .Include(a => a.Details)
            .ThenInclude(d => d.Question)
            .Where(a => a.UserId == userId && a.LessonId == lessonId)
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync();

        var result = attempts.Select(a => new QuizAttemptDto
        {
            Id = a.Id,
            LessonId = a.LessonId,
            Score = (double)a.Score,
            CorrectCount = a.CorrectCount,
            TotalQuestions = a.TotalQuestions,
            CreatedAt = a.CreatedAt,
            Details = a.Details.Select(d => new QuizAttemptDetailDto
            {
                Id = d.Id,
                QuestionId = d.QuestionId,
                QuestionText = d.Question!.QuestionText,
                SelectedOption = d.SelectedOption,
                CorrectOption = d.Question.CorrectOption,
                IsCorrect = d.IsCorrect,
                Explanation = d.Question.Explanation
            }).ToList()
        }).ToList();

        return Ok(result);
    }
}

