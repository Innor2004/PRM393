namespace PhysicsBook.Models.DTOs;

public class QuizAttemptDto
{
    public long Id { get; set; }
    public long LessonId { get; set; }
    public double Score { get; set; }
    public int CorrectCount { get; set; }
    public int TotalQuestions { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<QuizAttemptDetailDto> Details { get; set; } = new List<QuizAttemptDetailDto>();
}

public class QuizAttemptDetailDto
{
    public long Id { get; set; }
    public long QuestionId { get; set; }
    public string QuestionText { get; set; } = null!;
    public string? SelectedOption { get; set; }
    public string CorrectOption { get; set; } = null!;
    public bool IsCorrect { get; set; }
    public string? Explanation { get; set; }
}
