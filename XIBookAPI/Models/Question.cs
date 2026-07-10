using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace XIBookAPI.Models;

public class Question
{
    public long Id { get; set; }

    public long LessonId { get; set; }

    [Required]
    public string QuestionText { get; set; } = string.Empty;

    [Required, MaxLength(500)]
    public string OptionA { get; set; } = string.Empty;

    [Required, MaxLength(500)]
    public string OptionB { get; set; } = string.Empty;

    [Required, MaxLength(500)]
    public string OptionC { get; set; } = string.Empty;

    [Required, MaxLength(500)]
    public string OptionD { get; set; } = string.Empty;

    [Required, MaxLength(1)]
    public string CorrectOption { get; set; } = string.Empty;

    public string? Explanation { get; set; }

    [ForeignKey(nameof(LessonId))]
    public Lesson? Lesson { get; set; }
}
