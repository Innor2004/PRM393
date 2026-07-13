using System.ComponentModel.DataAnnotations;

namespace XIBookAPI.Models;

public class User
{
    public long Id { get; set; }

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [Required]
    [MaxLength(255)]
    public string Email { get; set; } = string.Empty;

    [Required]
    [MaxLength(500)]
    public string PasswordHash { get; set; } = string.Empty;

    [MaxLength(20)]
    public string Role { get; set; } = "Student";

    [MaxLength(500)]
    public string? AvatarUrl { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<Progress> Progresses { get; set; }
        = new List<Progress>();

    public ICollection<UserBadge> UserBadges { get; set; }
        = new List<UserBadge>();
}