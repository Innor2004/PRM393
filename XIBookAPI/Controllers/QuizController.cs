using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using XIBookAPI.Data;
using XIBookAPI.Models;
using XIBookAPI.Models.DTOs;

namespace XIBookAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class QuizController : ControllerBase
{
    private readonly AppDbContext _db;

    public QuizController(AppDbContext db) => _db = db;

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

        var progress = await _db.Progresses
            .FirstOrDefaultAsync(p => p.UserId == userId && p.LessonId == request.LessonId);

        if (progress == null)
        {
            progress = new Progress { UserId = userId, LessonId = request.LessonId };
            _db.Progresses.Add(progress);
        }

        progress.IsCompleted = true;
        progress.QuizScore = (decimal)score;
        progress.CompletionPercent = (decimal)(score >= 5 ? 100 : score * 10);
        progress.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(new QuizResultResponse(
            score, correctCount, questions.Count, details
        ));
    }
}
