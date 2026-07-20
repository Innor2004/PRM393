using System.ComponentModel.DataAnnotations.Schema;

namespace PhysicsBook.Models;

public class QuizAttempt
{
    public long Id { get; set; }

    public long UserId { get; set; }

    public long LessonId { get; set; }

    [Column(TypeName = "decimal(5,2)")]
    public decimal Score { get; set; }

    public int CorrectCount { get; set; }

    public int TotalQuestions { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [ForeignKey(nameof(UserId))]
    public User? User { get; set; }

    [ForeignKey(nameof(LessonId))]
    public Lesson? Lesson { get; set; }

    public ICollection<QuizAttemptDetail> Details { get; set; } = new List<QuizAttemptDetail>();
}
