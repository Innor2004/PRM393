using System.ComponentModel.DataAnnotations.Schema;

namespace XIBookAPI.Models;

public class Progress
{
    public long Id { get; set; }

    public long UserId { get; set; }

    public long LessonId { get; set; }

    public bool IsCompleted { get; set; } = false;

    [Column(TypeName = "decimal(5,2)")]
    public decimal QuizScore { get; set; } = 0;

    [Column(TypeName = "decimal(5,2)")]
    public decimal CompletionPercent { get; set; } = 0;

    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    [ForeignKey(nameof(UserId))]
    public User? User { get; set; }

    [ForeignKey(nameof(LessonId))]
    public Lesson? Lesson { get; set; }
}
