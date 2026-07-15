namespace PhysicsBook.Models.DTOs;

public record RegisterRequest(
    string Name,
    string Email,
    string Password
);

public record LoginRequest(
    string Email,
    string Password
);

public record UpdateProfileRequest(
    string Name
);

public record ChangePasswordRequest(
    string CurrentPassword,
    string NewPassword
);

public record AuthResponse(
    string Token,
    UserDto User
);

public record UserDto(
    long Id,
    string Name,
    string Email,
    string Role,
    string? AvatarUrl
);

public record QuizSubmitRequest(
    long LessonId,
    List<AnswerDto> Answers
);

public record AnswerDto(
    long QuestionId,
    string SelectedOption
);

public record QuizResultResponse(
    double Score,
    int CorrectCount,
    int TotalCount,
    List<AnswerResultDto> Details
);

public record AnswerResultDto(
    long QuestionId,
    string QuestionText,
    string CorrectOption,
    string? SelectedOption,
    bool IsCorrect,
    string? Explanation
);

public record ProgressResponse(
    long LessonId,
    bool IsCompleted,
    double QuizScore
);
