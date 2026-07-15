using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PhysicsBook.Models;

public class Chapter
{
    public long Id { get; set; }

    public long BookId { get; set; }

    [Required, MaxLength(255)]
    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    public int OrderIndex { get; set; }

    [ForeignKey(nameof(BookId))]
    public Book? Book { get; set; }

    public ICollection<Lesson> Lessons { get; set; } = new List<Lesson>();
}

