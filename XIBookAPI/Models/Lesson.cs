using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PhysicsBook.Models;

public class Lesson
{
    public long Id { get; set; }

    public long ChapterId { get; set; }

    [Required, MaxLength(255)]
    public string Title { get; set; } = string.Empty;

    public int OrderIndex { get; set; }

    public int EstimatedMinutes { get; set; } = 15;

    public int DifficultyStars { get; set; } = 1;

    public string? ContentBody { get; set; }

    [ForeignKey(nameof(ChapterId))]
    public Chapter? Chapter { get; set; }

    public ICollection<Question> Questions { get; set; } = new List<Question>();
    public ICollection<Progress> Progresses { get; set; } = new List<Progress>();
}

