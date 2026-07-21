using System;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using PhysicsBook.Models;

namespace PhysicsBook.Data;

public static class DbInitializer
{
    public static void Initialize(AppDbContext db)
    {
        // Ensure database is created without wiping data on restart
        db.Database.EnsureCreated();

        // Seed Users matching the Flutter app's mock/demo credentials
        if (!db.Users.Any())
        {
            db.Users.AddRange(
                new User
                {
                    Name = "Nam",
                    Email = "demo@test.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                    Role = "Student"
                },
                new User
                {
                    Name = "Quản trị viên",
                    Email = "admin@test.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
                    Role = "Admin"
                },
                new User
                {
                    Name = "Test 1",
                    Email = "test1@test.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                    Role = "Student"
                },
                new User
                {
                    Name = "Test 2",
                    Email = "test2@test.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                    Role = "Student"
                },
                new User
                {
                    Name = "Test 3",
                    Email = "test3@test.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                    Role = "Student"
                },
                new User
                {
                    Name = "User A",
                    Email = "usera@test.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                    Role = "Student"
                },
                new User
                {
                    Name = "User B",
                    Email = "userb@test.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                    Role = "Student"
                }
            );
            db.SaveChanges();
        }

        // Seed Badges
        if (!db.Badges.Any())
        {
            db.Badges.AddRange(
                new Badge { Name = "Nhà thám hiểm", Description = "Hoàn thành tất cả bài học với điểm trung bình từ 10.0 trở lên", IconUrl = "🏆", RequiredScore = 100 },
                new Badge { Name = "Nhà vật lý", Description = "Hoàn thành tất cả bài học với điểm trung bình từ 7.0 trở lên", IconUrl = "🌟", RequiredScore = 70 },
                new Badge { Name = "Học sinh chăm chỉ", Description = "Hoàn thành tất cả bài học", IconUrl = "⭐", RequiredScore = 0 }
            );
            db.SaveChanges();
        }

        // Seed Books
        if (!db.Books.Any())
        {
            var book = new Book
            {
                Title = "Vật lý đại cương",
                Description = "Sách điện tử Vật lý đại cương dành cho học sinh, sinh viên.",
                CoverImage = "assets/cover.png"
            };
            db.Books.Add(book);
            db.SaveChanges();

            // Seed Chapters
            var chapters = new[]
            {
                new Chapter { BookId = book.Id, Title = "Động học chất điểm", Description = "Chuyển động thẳng đều, biến đổi đều, rơi tự do", OrderIndex = 1 },
                new Chapter { BookId = book.Id, Title = "Động lực học chất điểm", Description = "Lực, khối lượng, định luật Newton", OrderIndex = 2 },
                new Chapter { BookId = book.Id, Title = "Cân bằng và chuyển động của vật rắn", Description = "Mô men lực, điều kiện cân bằng", OrderIndex = 3 },
                new Chapter { BookId = book.Id, Title = "Công và năng lượng", Description = "Công, động năng, thế năng, định luật bảo toàn", OrderIndex = 4 }
            };
            db.Chapters.AddRange(chapters);
            db.SaveChanges();

            // Seed Lessons
            var lessons = new[]
            {
                // Chapter 1 Lessons
                new Lesson { ChapterId = chapters[0].Id, Title = "Chuyển động thẳng đều", OrderIndex = 1, EstimatedMinutes = 20, DifficultyStars = 1, ContentBody = "# Bài 1: Chuyển động thẳng đều\n\n## 1. Định nghĩa\nChuyển động thẳng đều là chuyển động có quỹ đạo là đường thẳng và có vận tốc không đổi theo thời gian.\n\n## 2. Phương trình chuyển động\n`x = x₀ + v·t`\n\nTrong đó:\n- x: tọa độ tại thời điểm t (m)\n- x₀: tọa độ ban đầu (m)\n- v: vận tốc (m/s)\n- t: thời gian (s)\n\n## 3. Đồ thị tọa độ - thời gian\nĐồ thị tọa độ - thời gian của chuyển động thẳng đều là một đường thẳng xiên góc.\n\n## 4. Công thức tính quãng đường\n`s = v·t`\n\n## 5. Ví dụ\nMột xe chạy với vận tốc 15 m/s. Tính quãng đường xe đi được trong 10 giây.\nGiải: `s = v·t = 15·10 = 150 m`" },
                new Lesson { ChapterId = chapters[0].Id, Title = "Chuyển động thẳng biến đổi đều", OrderIndex = 2, EstimatedMinutes = 25, DifficultyStars = 3, ContentBody = "# Bài 2: Chuyển động thẳng biến đổi đều\n\n## 1. Định nghĩa\nChuyển động thẳng biến đổi đều là chuyển động có quỹ đạo là đường thẳng và có gia tốc không đổi.\n\n## 2. Gia tốc\n`a = (v - v₀) / t`\n\nĐơn vị: m/s²\n\n## 3. Các phương trình\n- Vận tốc: `v = v₀ + a·t`\n- Tọa độ: `x = x₀ + v₀·t + ½·a·t²`\n- Công thức độc lập với thời gian: `v² - v₀² = 2·a·s`\n\n## 4. Chuyển động nhanh dần đều và chậm dần đều\n- Nhanh dần đều: a × v > 0\n- Chậm dần đều: a × v < 0" },
                new Lesson { ChapterId = chapters[0].Id, Title = "Sự rơi tự do", OrderIndex = 3, EstimatedMinutes = 15, DifficultyStars = 2, ContentBody = "# Bài 3: Sự rơi tự do\n\n## 1. Định nghĩa\nSự rơi tự do là sự rơi chỉ dưới tác dụng của trọng lực.\n\n## 2. Đặc điểm\n- Phương thẳng đứng\n- Chiều từ trên xuống dưới\n- Chuyển động nhanh dần đều\n- Gia tốc: g ≈ 9.8 m/s²\n\n## 3. Công thức\n- `v = g·t`\n- `h = ½·g·t²`\n- `v² = 2·g·h`" },

                // Chapter 2 Lessons
                new Lesson { ChapterId = chapters[1].Id, Title = "Lực và khối lượng", OrderIndex = 1, EstimatedMinutes = 20, DifficultyStars = 2, ContentBody = "# Bài 4: Lực và khối lượng\n\n## 1. Khái niệm lực\nLực là đại lượng vectơ đặc trưng cho tác dụng của vật này lên vật khác, gây ra gia tốc hoặc biến dạng.\n\n## 2. Tổng hợp lực\nTổng hợp lực là thay thế nhiều lực bằng một lực có tác dụng tương đương.\n\nF = F₁ + F₂ (tổng vectơ)\n\n## 3. Phân tích lực\nPhân tích lực là thay thế một lực bằng hai lực tác dụng theo hai phương xác định." },
                new Lesson { ChapterId = chapters[1].Id, Title = "Định luật I Newton", OrderIndex = 2, EstimatedMinutes = 15, DifficultyStars = 3, ContentBody = "# Bài 5: Định luật I Newton\n\n## Nội dung định luật\nMột vật đang đứng yên sẽ tiếp tục đứng yên, đang chuyển động sẽ tiếp tục chuyển động thẳng đều, nếu không chịu tác dụng của lực nào hoặc chịu tác dụng của các lực cân bằng.\n\n## Quán tính\nQuán tính là tính chất bảo toàn trạng thái chuyển động của vật." },
                new Lesson { ChapterId = chapters[1].Id, Title = "Định luật II Newton", OrderIndex = 3, EstimatedMinutes = 20, DifficultyStars = 4, ContentBody = "# Bài 6: Định luật II Newton\n\n## Nội dung định luật\nGia tốc của một vật cùng hướng với lực tác dụng lên vật. Độ lớn của gia tốc tỉ lệ thuận với độ lớn của lực và tỉ lệ nghịch với khối lượng của vật.\n\n## Công thức\n`F = m·a`\n\nTrong đó:\n- F: lực tác dụng (N)\n- m: khối lượng (kg)\n- a: gia tốc (m/s²)" },

                // Chapter 3 Lessons
                new Lesson { ChapterId = chapters[2].Id, Title = "Mô men lực", OrderIndex = 1, EstimatedMinutes = 20, DifficultyStars = 3, ContentBody = "# Bài 7: Mô men lực\n\n## 1. Định nghĩa\nMô men lực là đại lượng đặc trưng cho tác dụng làm quay của lực.\n\n## 2. Công thức\n`M = F·d`\n\nTrong đó:\n- M: mô men lực (N·m)\n- F: lực tác dụng (N)\n- d: cánh tay đòn (m)\n\n## 3. Quy tắc mô men\nMuốn cho vật rắn cân bằng, tổng các mô men lực có xu hướng quay theo chiều kim đồng hồ bằng tổng các mô men lực có xu hướng quay ngược chiều kim đồng hồ." },
                new Lesson { ChapterId = chapters[2].Id, Title = "Điều kiện cân bằng của vật rắn", OrderIndex = 2, EstimatedMinutes = 20, DifficultyStars = 4, ContentBody = "# Bài 8: Điều kiện cân bằng của vật rắn\n\n## 1. Cân bằng của vật rắn chịu tác dụng của hai lực\nVật rắn cân bằng khi hai lực cùng giá, cùng độ lớn, ngược chiều.\n\n## 2. Cân bằng của vật rắn chịu tác dụng của ba lực\nBa lực phải đồng phẳng, đồng quy và hợp lực của hai lực cân bằng với lực thứ ba." },

                // Chapter 4 Lessons
                new Lesson { ChapterId = chapters[3].Id, Title = "Công cơ học", OrderIndex = 1, EstimatedMinutes = 15, DifficultyStars = 3, ContentBody = "# Bài 9: Công cơ học\n\n## 1. Định nghĩa\nCông cơ học là đại lượng đặc trưng cho tác dụng của lực làm vật di chuyển.\n\n## 2. Công thức\n`A = F·s·cos(α)`\n\nTrong đó:\n- A: công cơ học (J)\n- F: lực tác dụng (N)\n- s: quãng đường (m)\n- α: góc giữa lực và hướng chuyển động\n\n## 3. Công phát động và công cản\n- Công phát động: α < 90° → A > 0\n- Công cản: α > 90° → A < 0" },
                new Lesson { ChapterId = chapters[3].Id, Title = "Động năng và thế năng", OrderIndex = 2, EstimatedMinutes = 20, DifficultyStars = 4, ContentBody = "# Bài 10: Động năng và thế năng\n\n## 1. Động năng\nĐộng năng là năng lượng mà vật có được do chuyển động.\n\n`Wđ = ½·m·v²`\n\n## 2. Thế năng trọng trường\n`Wt = m·g·h`\n\n## 3. Định lý động năng\nĐộ biến thiên động năng bằng tổng công của ngoại lực.\n\nΔWđ = A" },
                new Lesson { ChapterId = chapters[3].Id, Title = "Định luật bảo toàn cơ năng", OrderIndex = 3, EstimatedMinutes = 20, DifficultyStars = 5, ContentBody = "# Bài 11: Định luật bảo toàn cơ năng\n\n## 1. Cơ năng\nCơ năng = Động năng + Thế năng\n`W = Wđ + Wt = ½·m·v² + m·g·h`\n\n## 2. Định luật bảo toàn cơ năng\nKhi vật chỉ chịu tác dụng của trọng lực và lực đàn hồi (lực thế), cơ năng của vật được bảo toàn.\n\nW₁ = W₂ = const\n\n## 3. Ứng dụng\nVật rơi tự do: thế năng giảm, động năng tăng, cơ năng không đổi." }
            };
            db.Lessons.AddRange(lessons);
            db.SaveChanges();

            // Seed Questions
            var questions = new[]
            {
                // Lesson 1 Questions
                new Question { LessonId = lessons[0].Id, QuestionText = "Chuyển động thẳng đều là chuyển động có:", OptionA = "Quỹ đạo là đường thẳng, vận tốc không đổi", OptionB = "Quỹ đạo là đường cong, vận tốc không đổi", OptionC = "Quỹ đạo là đường thẳng, vận tốc thay đổi", OptionD = "Quỹ đạo là đường cong, vận tốc thay đổi", CorrectOption = "A", Explanation = "Chuyển động thẳng đều có quỹ đạo là đường thẳng và vận tốc không đổi theo thời gian." },
                new Question { LessonId = lessons[0].Id, QuestionText = "Công thức tính quãng đường trong chuyển động thẳng đều là:", OptionA = "s = v/t", OptionB = "s = v × t", OptionC = "s = v² × t", OptionD = "s = t/v", CorrectOption = "B", Explanation = "Quãng đường s = v × t, trong đó v là vận tốc, t là thời gian." },
                new Question { LessonId = lessons[0].Id, QuestionText = "Đồ thị tọa độ - thời gian của chuyển động thẳng đều là:", OptionA = "Đường thẳng song song trục thời gian", OptionB = "Đường thẳng xiên góc", OptionC = "Đường parabol", OptionD = "Đường hypebol", CorrectOption = "B", Explanation = "Đồ thị tọa độ - thời gian là đường thẳng xiên góc, độ dốc bằng vận tốc." },

                // Lesson 2 Questions
                new Question { LessonId = lessons[1].Id, QuestionText = "Gia tốc của chuyển động thẳng biến đổi đều:", OptionA = "Thay đổi theo thời gian", OptionB = "Không đổi", OptionC = "Tỉ lệ với vận tốc", OptionD = "Tỉ lệ với thời gian", CorrectOption = "B", Explanation = "Trong chuyển động thẳng biến đổi đều, gia tốc không đổi theo thời gian." },
                new Question { LessonId = lessons[1].Id, QuestionText = "Công thức vận tốc trong chuyển động thẳng biến đổi đều:", OptionA = "v = v₀ + a×t", OptionB = "v = v₀ - a×t", OptionC = "v = v₀ + (1/2)×a×t²", OptionD = "v = v₀² + 2×a×s", CorrectOption = "A", Explanation = "Công thức v = v₀ + a×t là công thức vận tốc của chuyển động thẳng biến đổi đều." },

                // Lesson 3 Questions
                new Question { LessonId = lessons[2].Id, QuestionText = "Gia tốc rơi tự do trên Trái Đất xấp xỉ:", OptionA = "9.8 m/s²", OptionB = "4.9 m/s²", OptionC = "19.6 m/s²", OptionD = "0 m/s²", CorrectOption = "A", Explanation = "Gia tốc rơi tự do trên Trái Đất là g ≈ 9.8 m/s²." },

                // Lesson 4 Questions
                new Question { LessonId = lessons[3].Id, QuestionText = "Lực là đại lượng:", OptionA = "Vô hướng", OptionB = "Vectơ", OptionC = "Tensơ", OptionD = "Hằng số", CorrectOption = "B", Explanation = "Lực là đại lượng vectơ, có độ lớn, phương, chiều và điểm đặt." },

                // Lesson 5 Questions
                new Question { LessonId = lessons[4].Id, QuestionText = "Định luật I Newton còn gọi là:", OptionA = "Định luật quán tính", OptionB = "Định luật gia tốc", OptionC = "Định luật phản lực", OptionD = "Định luật hấp dẫn", CorrectOption = "A", Explanation = "Định luật I Newton còn gọi là định luật quán tính." },

                // Lesson 6 Questions
                new Question { LessonId = lessons[5].Id, QuestionText = "Công thức của định luật II Newton là:", OptionA = "F = m/a", OptionB = "F = m × a", OptionC = "F = m + a", OptionD = "F = m - a", CorrectOption = "B", Explanation = "Định luật II Newton: F = m × a, gia tốc cùng hướng với lực." },

                // Lesson 7 Questions
                new Question { LessonId = lessons[6].Id, QuestionText = "Đơn vị của mô men lực là:", OptionA = "N.m", OptionB = "N/m", OptionC = "N.s", OptionD = "N/kg", CorrectOption = "A", Explanation = "Mô men lực có đơn vị là N.m (Newton mét)." },

                // Lesson 9 Questions
                new Question { LessonId = lessons[8].Id, QuestionText = "Đơn vị của công cơ học là:", OptionA = "Watt (W)", OptionB = "Joule (J)", OptionC = "Newton (N)", OptionD = "Pascal (Pa)", CorrectOption = "B", Explanation = "Công cơ học có đơn vị là Joule (J)." },

                // Lesson 11 Questions
                new Question { LessonId = lessons[10].Id, QuestionText = "Khi vật rơi tự do, cơ năng:", OptionA = "Tăng dần", OptionB = "Giảm dần", OptionC = "Không đổi", OptionD = "Bằng 0", CorrectOption = "C", Explanation = "Khi vật rơi tự do, thế năng chuyển hóa thành động năng, cơ năng bảo toàn." }
            };
            db.Questions.AddRange(questions);
            db.SaveChanges();
        }
    }
}

