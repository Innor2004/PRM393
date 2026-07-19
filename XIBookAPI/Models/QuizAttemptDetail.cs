using System.ComponentModel.DataAnnotations.Schema;

namespace PhysicsBook.Models;

public class QuizAttemptDetail
{
    public long Id { get; set; }

    public long QuizAttemptId { get; set; }

    public long QuestionId { get; set; }

    public string? SelectedOption { get; set; }

    public bool IsCorrect { get; set; }

    [ForeignKey(nameof(QuizAttemptId))]
    public QuizAttempt? QuizAttempt { get; set; }

    [ForeignKey(nameof(QuestionId))]
    public Question? Question { get; set; }
}
