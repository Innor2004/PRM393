using System.ComponentModel.DataAnnotations;

namespace PhysicsBook.Models;

public class Badge
{
    public long Id { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? Description { get; set; }

    [MaxLength(500)]
    public string? IconUrl { get; set; }

    public int RequiredScore { get; set; } = 0;

    public ICollection<UserBadge> UserBadges { get; set; } = new List<UserBadge>();
}

