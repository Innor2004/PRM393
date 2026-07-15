using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhysicsBook.Data;

namespace PhysicsBook.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BadgesController : ControllerBase
{
    private readonly AppDbContext _db;

    public BadgesController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<ActionResult> GetAll()
    {
        var badges = await _db.Badges
            .Select(b => new
            {
                b.Id,
                b.Name,
                b.Description,
                b.IconUrl,
                b.RequiredScore
            })
            .ToListAsync();

        return Ok(new { data = badges });
    }

    [HttpGet("mine")]
    public async Task<ActionResult> GetMine()
    {
        var userId = long.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var badges = await _db.UserBadges
            .Where(ub => ub.UserId == userId)
            .Select(ub => new
            {
                ub.Badge.Id,
                ub.Badge.Name,
                ub.Badge.Description,
                ub.Badge.IconUrl,
                ub.EarnedAt
            })
            .ToListAsync();

        return Ok(new { data = badges });
    }
}

