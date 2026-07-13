using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using XIBookAPI.Data;
using XIBookAPI.Models;
using XIBookAPI.Models.DTOs;
using XIBookAPI.Services;

namespace XIBookAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly JwtService _jwt;

    public AuthController(
        AppDbContext db,
        JwtService jwt
    )
    {
        _db = db;
        _jwt = jwt;
    }

    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> Register(
        RegisterRequest request
    )
    {
        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return BadRequest(new
            {
                message = "Vui lòng nhập họ và tên"
            });
        }

        if (request.Name.Trim().Length < 2 ||
            request.Name.Trim().Length > 100)
        {
            return BadRequest(new
            {
                message = "Tên phải từ 2 đến 100 ký tự"
            });
        }

        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return BadRequest(new
            {
                message = "Vui lòng nhập email"
            });
        }

        if (string.IsNullOrWhiteSpace(request.Password) ||
            request.Password.Length < 6)
        {
            return BadRequest(new
            {
                message = "Mật khẩu phải có ít nhất 6 ký tự"
            });
        }

        var email = request.Email
            .Trim()
            .ToLowerInvariant();

        var emailExists = await _db.Users.AnyAsync(
            user => user.Email == email
        );

        if (emailExists)
        {
            return BadRequest(new
            {
                message = "Email đã tồn tại"
            });
        }

        var user = new User
        {
            Name = request.Name.Trim(),
            Email = email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(
                request.Password
            ),
            Role = "Student"
        };

        _db.Users.Add(user);

        await _db.SaveChangesAsync();

        var token = _jwt.GenerateToken(user);

        return Ok(
            new AuthResponse(
                token,
                MapUser(user)
            )
        );
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> Login(
        LoginRequest request
    )
    {
        if (string.IsNullOrWhiteSpace(request.Email) ||
            string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new
            {
                message = "Vui lòng nhập email và mật khẩu"
            });
        }

        var email = request.Email
            .Trim()
            .ToLowerInvariant();

        var user = await _db.Users.FirstOrDefaultAsync(
            item => item.Email == email
        );

        if (user == null ||
            !BCrypt.Net.BCrypt.Verify(
                request.Password,
                user.PasswordHash
            ))
        {
            return Unauthorized(new
            {
                message = "Email hoặc mật khẩu không đúng"
            });
        }

        var token = _jwt.GenerateToken(user);

        return Ok(
            new AuthResponse(
                token,
                MapUser(user)
            )
        );
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<UserDto>> GetMe()
    {
        var user = await FindCurrentUserAsync();

        if (user == null)
        {
            return NotFound(new
            {
                message = "Không tìm thấy người dùng"
            });
        }

        return Ok(MapUser(user));
    }

    // Sửa tên
    [HttpPut("profile")]
    [Authorize]
    public async Task<ActionResult<UserDto>> UpdateProfile(
        UpdateProfileRequest request
    )
    {
        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return BadRequest(new
            {
                message = "Vui lòng nhập họ và tên"
            });
        }

        var name = request.Name.Trim();

        if (name.Length < 2 || name.Length > 100)
        {
            return BadRequest(new
            {
                message = "Tên phải từ 2 đến 100 ký tự"
            });
        }

        var user = await FindCurrentUserAsync();

        if (user == null)
        {
            return NotFound(new
            {
                message = "Không tìm thấy người dùng"
            });
        }

        user.Name = name;

        await _db.SaveChangesAsync();

        return Ok(MapUser(user));
    }

    // Đổi mật khẩu
    [HttpPut("password")]
    [Authorize]
    public async Task<IActionResult> ChangePassword(
        ChangePasswordRequest request
    )
    {
        if (string.IsNullOrWhiteSpace(request.CurrentPassword))
        {
            return BadRequest(new
            {
                message = "Vui lòng nhập mật khẩu hiện tại"
            });
        }

        if (string.IsNullOrWhiteSpace(request.NewPassword) ||
            request.NewPassword.Length < 6 ||
            request.NewPassword.Length > 100)
        {
            return BadRequest(new
            {
                message = "Mật khẩu mới phải từ 6 đến 100 ký tự"
            });
        }

        if (request.CurrentPassword == request.NewPassword)
        {
            return BadRequest(new
            {
                message = "Mật khẩu mới phải khác mật khẩu hiện tại"
            });
        }

        var user = await FindCurrentUserAsync();

        if (user == null)
        {
            return NotFound(new
            {
                message = "Không tìm thấy người dùng"
            });
        }

        var passwordIsCorrect = BCrypt.Net.BCrypt.Verify(
            request.CurrentPassword,
            user.PasswordHash
        );

        if (!passwordIsCorrect)
        {
            return BadRequest(new
            {
                message = "Mật khẩu hiện tại không đúng"
            });
        }

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(
            request.NewPassword
        );

        await _db.SaveChangesAsync();

        return Ok(new
        {
            message = "Đổi mật khẩu thành công"
        });
    }

    // Upload ảnh đại diện
    [HttpPost("avatar")]
    [Authorize]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(5 * 1024 * 1024)]
    public async Task<ActionResult<UserDto>> UploadAvatar(
        [FromForm] IFormFile avatar
    )
    {
        if (avatar == null || avatar.Length == 0)
        {
            return BadRequest(new
            {
                message = "Vui lòng chọn ảnh"
            });
        }

        if (avatar.Length > 5 * 1024 * 1024)
        {
            return BadRequest(new
            {
                message = "Ảnh không được lớn hơn 5 MB"
            });
        }

        var extension = Path.GetExtension(
            avatar.FileName
        ).ToLowerInvariant();

        var allowedExtensions = new[]
        {
            ".jpg",
            ".jpeg",
            ".png",
            ".webp"
        };

        if (!allowedExtensions.Contains(extension))
        {
            return BadRequest(new
            {
                message = "Chỉ hỗ trợ ảnh JPG, JPEG, PNG hoặc WEBP"
            });
        }

        if (!avatar.ContentType.StartsWith(
                "image/",
                StringComparison.OrdinalIgnoreCase
            ))
        {
            return BadRequest(new
            {
                message = "File được chọn không phải là hình ảnh"
            });
        }

        var user = await FindCurrentUserAsync();

        if (user == null)
        {
            return NotFound(new
            {
                message = "Không tìm thấy người dùng"
            });
        }

        var uploadDirectory = Path.Combine(
            Directory.GetCurrentDirectory(),
            "wwwroot",
            "uploads",
            "avatars"
        );

        Directory.CreateDirectory(uploadDirectory);

        var fileName =
            $"user_{user.Id}_{Guid.NewGuid():N}{extension}";

        var filePath = Path.Combine(
            uploadDirectory,
            fileName
        );

        await using (var stream = System.IO.File.Create(filePath))
        {
            await avatar.CopyToAsync(stream);
        }

        user.AvatarUrl =
            $"{Request.Scheme}://{Request.Host}/uploads/avatars/{fileName}";

        await _db.SaveChangesAsync();

        return Ok(MapUser(user));
    }

    private async Task<User?> FindCurrentUserAsync()
    {
        var userIdValue = User.FindFirst(
            ClaimTypes.NameIdentifier
        )?.Value;

        if (!long.TryParse(
                userIdValue,
                out var userId
            ))
        {
            return null;
        }

        return await _db.Users.FindAsync(userId);
    }

    private static UserDto MapUser(User user)
    {
        return new UserDto(
            user.Id,
            user.Name,
            user.Email,
            user.Role,
            user.AvatarUrl
        );
    }
}