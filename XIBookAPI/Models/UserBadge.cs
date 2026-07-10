using System.ComponentModel.DataAnnotations.Schema;

namespace XIBookAPI.Models;

public class UserBadge
{
    public long Id { get; set; }

    public long UserId { get; set; }

    public long BadgeId { get; set; }

    public DateTime EarnedAt { get; set; } = DateTime.UtcNow;

    [ForeignKey(nameof(UserId))]
    public User? User { get; set; }

    [ForeignKey(nameof(BadgeId))]
    public Badge? Badge { get; set; }
}
